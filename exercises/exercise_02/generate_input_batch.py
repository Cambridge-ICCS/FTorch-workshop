#!/usr/bin/env python3
"""Preprocess an image for ResNet-18 inference."""

import os

import numpy as np
import torch
import torchvision
from PIL import Image


def preprocess_image(image_path: str) -> torch.Tensor:
    """
    Load and preprocess a single image for ResNet-18.

    Parameters
    ----------
    image_path : str
        Path to the image file.

    Returns
    -------
    torch.Tensor
        Preprocessed image tensor of shape [3, 224, 224].
    """
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
    data_dir = os.path.join(os.path.dirname(__file__), "data")
    np_precision = np.float32

    # Preprocess a single image
    input_tensor = preprocess_image(os.path.join(data_dir, "dog.jpg"))

    # TODO: Extend this script to batch multiple images.
    #       1. Add a --batch_size command-line argument.
    #       2. Load a different image for each index (dog2.jpg is provided).
    #       3. Stack them into a batch with torch.stack().
    #       4. Save the batched array (shape [N, 3, 224, 224]) instead.
    #       You will also need to update the Fortran code to match.

    # Transpose so memory order is consistent with Fortran column-major layout
    np_input = np.array(input_tensor.numpy().transpose().flatten(), dtype=np_precision)

    # Save as binary for Fortran to read
    out_file = os.path.join(data_dir, "image_tensor.dat")
    np_input.tofile(out_file)
    print(f"Generated {out_file}")
