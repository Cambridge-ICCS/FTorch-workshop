# Exercise 2 - Real-world inference with ResNet-18

## Description

This exercise demonstrates a more realistic FTorch workflow using a pre-trained
ResNet-18 model from TorchVision to classify images.

You will:

- Work with a **real-world** pre-trained model (not a toy example).
- Learn why the **batch dimension** is needed for multidimensional data.
- Explore **batching** — processing multiple images in a single forward pass.
- Follow the **full Python-to-Fortran pipeline**.

The model takes a 4-dimensional input tensor with shape `(batch, channels, height, width)`.
Handling this multidimensional data requires care with memory layout — see
[A note on data layout](#a-note-on-data-layout).

## Stage 1: Single-image inference

### 1. Generate input data

Run the Python script to preprocess the example image (`data/dog.jpg`):

```
python3 generate_input_batch.py
```

This saves the preprocessed image as `data/image_tensor.dat`.

### 2. Convert to TorchScript

The `pt2ts` command can load a pre-trained model directly from TorchVision:

```
pt2ts resnet18 \
  --model_weights IMAGENET1K_V1 \
  --output_model_file torchscript_resnet18_model_cpu.pt
```

### 3. Fortran inference (single image)

Build the Fortran code using CMake:

```
cmake -B build
cd build
cmake --build .
```

Run with the model file:

```
./resnet_infer_fortran ../torchscript_resnet18_model_cpu.pt
```

Expected output:
```
Samoyed, probability 0.8846
```

#### Fortran tasks

The file `resnet_infer_fortran.f90` contains a skeleton with `! TODO` comments.
Fill them in to complete the inference pipeline:

1. **Import** the `ftorch` module.
2. **Declare** a `torch_model` and `torch_tensor` variables.
3. **Create tensors** from the Fortran arrays using `torch_tensor_from_array`.
4. **Load the model** using `torch_model_load`.
5. **Run inference** using `torch_model_forward`.
6. **Clean up** using `torch_delete`.

**A challenge**: the ResNet model expects a 4-dimensional input tensor with
shape `(batch, channels, height, width)`, but the data array is currently
3-dimensional `(3, 224, 224)`. You will need to handle this difference to
make the inference work.

For a complete reference, see `resnet_infer_fortran_sol.f90`.

### Verification with Python

You can verify the TorchScript model against the same data:

```
python3 resnet_infer_python.py
```

## Stage 2: Extend to batched inference

Once single-image inference is working, extend both the Python and Fortran
code to handle batches of images.

### Python: generate a batch

Extend `generate_input_batch.py` to:

1. Accept a `--batch_size` command-line argument.
2. Load a different image for each index (a second image `data/dog2.jpg`
   is provided).
3. Stack the preprocessed images with `torch.stack()` into a batch of
   shape `[N, 3, 224, 224]`.
4. Save the batched array as `data/image_batch_N.dat` (with the transpose
   applied to the full batch).

Run it:

```
python3 generate_input_batch.py --batch_size 2
```

### Fortran: process a batch

Extend `resnet_infer_fortran.f90` to:

1. Accept an optional batch size as a second command-line argument.
2. Allocate `in_data` and `out_data` as 4D arrays with the batch dimension.
3. Read the appropriate `image_batch_N.dat` file.
4. Output the top result for each image in the batch.

Run with different batch sizes:

```
./resnet_infer_fortran ../torchscript_resnet18_model_cpu.pt 2
./resnet_infer_fortran ../torchscript_resnet18_model_cpu.pt 4
./resnet_infer_fortran ../torchscript_resnet18_model_cpu.pt 8
```

### Verify in Python

```
python3 resnet_infer_python.py --batch_size 2
```

## Expected results

For the single image (`data/dog.jpg`):
```
Samoyed, probability 0.8846
```

## A note on data layout

The ResNet-18 input is a 4-dimensional tensor with shape
`(batch, channels, height, width)`. However, Python (C) and Fortran store
multidimensional arrays in opposite memory order:

- **C / Python**: row-major — the last dimension changes fastest.
- **Fortran**: column-major — the first dimension changes fastest.

To ensure the data is laid out correctly in memory for Fortran, the Python
script transposes the tensor before saving to binary:

```python
np_input = np_input.transpose().flatten()
```

`transpose()` reverses the index order from `[B, C, H, W]` to `[W, H, C, B]`.
When Fortran then reads the flat binary and `reshape`s it into its own
`(B, C, H, W)` array, the elements fall into the expected positions.

For a more detailed discussion, see the FTorch documentation on
[when to transpose arrays](https://cambridge-iccs.github.io/FTorch/page/usage/transposing.html).
