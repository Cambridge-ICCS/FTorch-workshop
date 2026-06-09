#!/usr/bin/env python3
"""Load TorchScript ResNet-18 model and run inference."""

import os

import numpy as np
import torch


def load_labels(data_dir):
    labels = []
    with open(os.path.join(data_dir, "categories.txt")) as f:
        for line in f:
            labels.append(line.strip())
    return labels


def softmax(x):
    e_x = np.exp(x - np.max(x))
    return e_x / e_x.sum()


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "--model",
        help="Path to the TorchScript model file",
        type=str,
        default="torchscript_resnet18_model_cpu.pt",
    )
    parser.add_argument(
        "--batch_size",
        help="Number of images in the batch",
        type=int,
        default=1,
    )
    parser.add_argument(
        "--data_dir",
        help="Path to the data directory",
        type=str,
        default=os.path.join(os.path.dirname(__file__), "data"),
    )
    parsed_args = parser.parse_args()
    model_file = parsed_args.model
    batch_size = parsed_args.batch_size
    data_dir = parsed_args.data_dir

    labels = load_labels(data_dir)
    np_precision = np.float32

    model = torch.jit.load(model_file)
    model.eval()

    in_file = os.path.join(data_dir, f"image_batch_{batch_size}.dat")
    in_data = np.fromfile(in_file, dtype=np_precision)

    # Data was saved with transpose for Fortran column-major layout.
    # Undo the transpose: reshape as (W, H, C, B) then transpose back.
    in_data = in_data.reshape(224, 224, 3, batch_size)
    in_data = in_data.transpose()  # back to (B, 3, 224, 224)

    in_tensor = torch.from_numpy(in_data.copy())

    with torch.no_grad():
        out_tensor = model(in_tensor)

    out_data = out_tensor.numpy()

    for i in range(batch_size):
        probabilities = softmax(out_data[i])
        max_idx = np.argmax(probabilities)
        print(f"Image {i}: {labels[max_idx]}, probability {probabilities[max_idx]:.4f}")
