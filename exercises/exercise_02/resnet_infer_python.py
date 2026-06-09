#!/usr/bin/env python3
"""Load TorchScript ResNet-18 model and run inference on a single image."""

import os

import numpy as np
import torch
import torchvision


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "--model_file",
        help="Path to TorchScript model file",
        type=str,
        default="torchscript_resnet18_model_cpu.pt",
    )
    parser.add_argument(
        "--data_dir",
        help="Path to the data directory",
        type=str,
        default=os.path.join(os.path.dirname(__file__), "data"),
    )
    parser.add_argument(
        "--precision",
        help="Working precision",
        type=str,
        default="float32",
    )
    parsed_args = parser.parse_args()
    model_file = parsed_args.model_file
    data_dir = parsed_args.data_dir
    precision = getattr(np, parsed_args.precision)

    # Read transposed binary data for a single image
    transposed_shape = [224, 224, 3]
    tensor_file = os.path.join(data_dir, "image_tensor.dat")
    np_data = np.fromfile(tensor_file, dtype=precision)
    np_data = np_data.reshape(transposed_shape)
    np_data = np_data.transpose()
    input_tensor = torch.from_numpy(np_data)

    # TODO: Extend this script for batched inference.
    #       1. Add a --batch_size argument.
    #       2. Read from image_batch_N.dat instead.
    #       3. Reshape with batch dimension: [224, 224, 3, N].

    # Add batch dimension and load model
    input_batch = input_tensor.unsqueeze(0)
    model = torch.jit.load(model_file)

    with torch.inference_mode():
        output = model.forward(input_batch)

    # Print top result
    probabilities = torch.nn.functional.softmax(output[0], dim=0)
    top_prob, top_idx = torch.topk(probabilities, 1)
    print(
        f"class {top_idx.item()}, probability = {top_prob.item():.6f}"
    )
    print("Python verification passed.")
