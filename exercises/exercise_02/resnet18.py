#!/usr/bin/env python3
"""Load pretrained ResNet-18 and prepare for Fortran inference."""

import os

import numpy as np
import torch
import torchvision
from PIL import Image


def initialize(precision: torch.dtype) -> torch.nn.Module:
    """
    Download pre-trained ResNet-18 model and prepare for inference.

    Parameters
    ----------
    precision: torch.dtype
        Sets the working precision of the model.

    Returns
    -------
    model: torch.nn.Module
        Pretrained ResNet-18 model
    """
    torch.set_default_dtype(precision)
    print("Loading pre-trained ResNet-18 model...", end="")
    model = torchvision.models.resnet18(weights="IMAGENET1K_V1")
    model.eval()
    print("done.")
    return model


def check_results(output: torch.Tensor) -> None:
    """
    Compare top model output to expected result.

    Parameters
    ----------
    output: torch.Tensor
        Output from ResNet-18.
    """
    predicted_prob = torch.max(torch.nn.functional.softmax(output[0], dim=0))
    expected_prob = 0.8846225142478943
    if not torch.isclose(predicted_prob, expected_prob, atol=1e-5):
        raise ValueError(
            f"Predicted probability {predicted_prob} does not match "
            f"expected value {expected_prob}."
        )


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

    # Specify working precision
    np_precision = np.float32
    torch_precision = torch.float32

    # Initialize model
    model = initialize(torch_precision)

    # Preprocess the example image
    image_path = os.path.join(data_dir, "dog.jpg")
    input_tensor = preprocess_image(image_path)

    # TODO: Extend this to batch multiple images.
    #       Currently we unsqueeze to shape [1, 3, 224, 224] for a single image.
    #       Try loading additional images, preprocessing them, and stacking them
    #       into a batch (e.g., shape [N, 3, 224, 224]).
    input_batch = input_tensor.unsqueeze(0)
    batch_size = input_batch.shape[0]

    # Transpose input before saving so order matches Fortran column-major layout
    np_input = np.array(input_batch.numpy().transpose().flatten(), dtype=np_precision)

    # Save preprocessed input as binary for Fortran to read
    tensor_filename = os.path.join(data_dir, "image_tensor.dat")
    np_input.tofile(tensor_filename)

    # Save model state dict for pt2ts conversion
    torch.save(
        model.state_dict(),
        "pytorch_resnet18_model_cpu.pt",
    )

    # Run inference in Python to verify
    with torch.inference_mode():
        output = model(input_batch)
    check_results(output)

    # Print top result
    probabilities = torch.nn.functional.softmax(output[0], dim=0)
    top_prob, top_idx = torch.topk(probabilities, 1)
    print(
        f"Top prediction: class {top_idx.item()}, probability = {top_prob.item():.6f}"
    )
    print(f"Input batch included {batch_size} image(s).")
