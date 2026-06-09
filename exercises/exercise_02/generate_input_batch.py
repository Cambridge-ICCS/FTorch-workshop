#!/usr/bin/env python3
"""Preprocess images for ResNet-18 inference."""

import os

import numpy as np
import torch
import torchvision
from PIL import Image


def preprocess_image(image_path: str) -> torch.Tensor:
    input_image = Image.open(image_path)
    preprocess = torchvision.transforms.Compose(
        [
            torchvision.transforms.Resize(256),
            torchvision.transforms.CenterCrop(224),
            torchvision.transforms.ToTensor(),
            torchvision.transforms.Normalize(
                mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]
            ),
        ]
    )
    return preprocess(input_image)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "--batch_size",
        help="Number of images to batch together",
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
    batch_size = parsed_args.batch_size
    data_dir = parsed_args.data_dir
    np_precision = np.float32

    # TODO: Use a different image for each batch element.
    #       Currently all images are the same (dog.jpg).
    #       Two images are provided: data/dog.jpg and data/dog2.jpg.
    #       For larger batches add more images to data/.
    input_batch = []
    for i in range(batch_size):
        # image_path = os.path.join(data_dir, f"dog{i+1}.jpg")
        image_path = os.path.join(data_dir, "dog.jpg")
        input_tensor = preprocess_image(image_path)
        input_batch.append(input_tensor.unsqueeze(0).numpy())

    # Stack images and transpose for Fortran column-major layout
    np_input = np.array(np.vstack(input_batch), dtype=np_precision)
    np_input = np_input.transpose().flatten()

    out_file = os.path.join(data_dir, f"image_batch_{batch_size}.dat")
    np_input.tofile(out_file)
    print(f"Generated {out_file} with batch size {batch_size}.")
