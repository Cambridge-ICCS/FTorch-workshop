#!/usr/bin/env python3
"""Load TorchScript ResNet-18 model and run inference for verification."""

import os

import numpy as np
import torch
from resnet18 import check_results

if __name__ == "__main__":
    data_dir = os.path.join(os.path.dirname(__file__), "data")
    model_file = "torchscript_resnet18_model_cpu.pt"
    precision = np.float32

    # Read transposed binary data saved by resnet18.py and restore shape
    transposed_shape = [224, 224, 3, 1]
    np_data = np.fromfile(os.path.join(data_dir, "image_tensor.dat"), dtype=precision)
    np_data = np_data.reshape(transposed_shape)
    np_data = np_data.transpose()
    input_tensor = torch.from_numpy(np_data)

    # Load TorchScript model and run inference
    model = torch.jit.load(model_file)
    with torch.inference_mode():
        output = model.forward(input_tensor)

    check_results(output)

    probabilities = torch.nn.functional.softmax(output[0], dim=0)
    top_prob, top_idx = torch.topk(probabilities, 1)
    print(
        f"Top prediction: class {top_idx.item()}, probability = {top_prob.item():.6f}"
    )
    print("Python verification passed.")
