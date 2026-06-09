# Exercise 2 - Real-world inference with ResNet-18

## Description

This exercise demonstrates a more realistic FTorch workflow using a pre-trained
ResNet-18 model from TorchVision to classify an image of a Samoyed dog.

You will:

- Work with a **real-world** pre-trained model (not a toy example).
- Explore **batching** — processing multiple images in a single forward pass.
- Follow the **full Python-to-Fortran pipeline**: generate input data in Python,
  convert the model to TorchScript, then call from Fortran.

The model takes a 4-dimensional input tensor with shape `(batch, channels, height, width)`.
Handling this multidimensional data requires care with memory layout — see
[A note on data layout](#a-note-on-data-layout).

## The pipeline

There are three stages to this exercise:

1. **Python**: Run `generate_input_batch.py` with a batch size to preprocess
   images and write them as a binary tensor.
2. **Convert**: Use the `pt2ts` command to download the pre-trained ResNet-18
   from TorchVision and save it as TorchScript.
3. **Fortran**: Write Fortran code using FTorch to load the TorchScript model
   and run inference on the batch.

## Running

### 1. Generate input data

Create a batch of preprocessed images for Fortran:

```
python3 generate_input_batch.py 1
```

This preprocesses `data/dog.jpg` and saves it as `data/image_batch_1.dat`.

Expected output:
```
Generated data/image_batch_1.dat with batch size 1.
```

#### Python task: Implement batching

Look at the `# TODO` comments in `generate_input_batch.py`. Currently every
element of the batch uses `dog.jpg`. Two images are provided — `data/dog.jpg`
and `data/dog2.jpg`. Extend the script to:

1. Use a different image for each index in the batch (controlled by the loop
   variable `i`).
2. For larger batches, add more images to `data/`.

Re-run with a larger batch size to confirm it works:

```
python3 generate_input_batch.py 2
```

### 2. Convert to TorchScript

The `pt2ts` command-line tool can load a pre-trained model directly from
TorchVision by name, without needing a model definition file:

```
pt2ts resnet18 \
  --model_weights IMAGENET1K_V1 \
  --output_model_file torchscript_resnet18_model_cpu.pt
```

This downloads ResNet-18 with ImageNet weights and saves it as TorchScript.
The `--test` flag can be added to verify the output.

### 3. Fortran inference

Build the Fortran code using CMake:

```
cmake -B build
cd build
cmake --build .
```

Run with the model file, batch size, and optionally the data directory:

```
./resnet_infer_fortran ../torchscript_resnet18_model_cpu.pt 1
```

Expected output:
```
1: Samoyed, probability 0.8846
```

#### Fortran tasks

The file `resnet_infer_fortran.f90` contains a skeleton with `! TODO` comments.
Fill them in to complete the inference pipeline:

1. **Import** the `ftorch` module.
2. **Declare** a `torch_model` and `torch_tensor` variables.
3. **Create tensors** from the Fortran arrays using `torch_tensor_from_array`.
4. **Load the model** using `torch_model_load`.
5. **Run inference** using `torch_model_forward`.
6. **Clean up** using `torch_delete` and `deallocate`.

For a complete reference, see `resnet_infer_fortran_sol.f90`.

#### Explore batching

Try different batch sizes:

```
./resnet_infer_fortran ../torchscript_resnet18_model_cpu.pt 2
./resnet_infer_fortran ../torchscript_resnet18_model_cpu.pt 4
./resnet_infer_fortran ../torchscript_resnet18_model_cpu.pt 8
```

Each requires the corresponding `image_batch_N.dat` file — re-run
`generate_input_batch.py` with each batch size first.

### Verification with Python

You can verify the TorchScript model against the same batch data:

```
python3 resnet_infer_python.py 1
```

## A note on data layout

The input image is a 4-dimensional tensor with shape `(batch, channels, height, width)`.
However, Python (C) and Fortran store multidimensional arrays in opposite memory order:

- **C / Python**: row-major — the last dimension changes fastest.
- **Fortran**: column-major — the first dimension changes fastest.

To ensure the data is laid out correctly in memory for Fortran, the Python
script transposes the tensor before saving to binary:

```python
np_input = np_input.transpose().flatten()
```

`transpose()` reverses the index order from `[B, C, H, W]` to `[W, H, C, B]`.
When Fortran then reads the flat binary and `reshape`s it into its own
`[B, C, H, W]` array, the elements fall into the expected positions.

For a more detailed discussion, see the FTorch documentation on
[when to transpose arrays](https://cambridge-iccs.github.io/FTorch/page/usage/transposing.html).
