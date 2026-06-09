# Exercise 2 - Real-world inference with ResNet-18

## Description

This exercise demonstrates a more realistic FTorch workflow using a pre-trained
ResNet-18 model from TorchVision to classify images.

The exercise has two stages:

1. **Single-image inference** — arrays are 3D (no batch dimension). You use
   `torch_tensor_from_blob` to create a 4D tensor view for the model.
2. **Add batching** — arrays become 4D with dynamic `batch_size`. You switch
   to `torch_tensor_from_array`. The `batch_size` CLI arg is already available.

## Stage 1: Single-image inference

### 1. Generate input data

Run the Python script to preprocess the example image (`data/dog.jpg`):

```
python3 generate_input_batch.py
```

This saves the preprocessed image as `data/image_batch_1.dat`.

### 2. Convert to TorchScript

```
pt2ts resnet18 \
  --model_weights IMAGENET1K_V1 \
  --output_model_file torchscript_resnet18_model_cpu.pt
```

### 3. Fortran inference

Build using CMake:

```
cmake -B build
cd build
cmake --build .
```

Run:

```
./resnet_infer_fortran ../torchscript_resnet18_model_cpu.pt
```

Expected output:
```
Samoyed, probability 0.8846
```

#### Fortran TODOs

The file `resnet_infer_fortran.f90` has 6 TODO comments:

1. **Import** the `ftorch` module.
2. **Create tensors** — the Fortran arrays are 3D (`in_data(3,224,224)`,
   `out_data(1000)`) but the model expects 4D input and 2D output. Use
   `torch_tensor_from_blob` to create tensors with the batch dimension
   included in the shape.
3. **Load the model** using `torch_model_load`.
4. **Run inference** using `torch_model_forward`.
5. **Classify results** for each image in the batch.
6. **Clean up** using `torch_delete`.

See `resnet_infer_fortran_sol.f90` for a complete reference.

### Verification with Python

```
python3 resnet_infer_python.py
```

## Stage 2: Add batching

The `--batch_size` / `batch_size` argument is already wired in — default 1.

### Extend the Fortran code

1. Change `in_data` from 3D `(3,224,224)` to 4D `(batch_size,3,224,224)`.
2. Change `out_data` from 1D `(1000)` to 2D `(batch_size,1000)`.
3. Replace `torch_tensor_from_blob` with `torch_tensor_from_array` — the
   batch dimension is now in the array shape, so no extra shape info is needed.
4. Loop over all batch elements in the classify step.

### Generate a batch

In `generate_input_batch.py`, update the image path TODO to use a different
image for each batch element. Two images are provided: `data/dog.jpg`
and `data/dog2.jpg`. For larger batches, add more images.

```
python3 generate_input_batch.py --batch_size 2
```

### Run with the batch

```
./resnet_infer_fortran ../torchscript_resnet18_model_cpu.pt 2
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
`(batch, channels, height, width)`. Python (C) and Fortran store arrays
in opposite memory order:

- **C / Python**: row-major (last dimension varies fastest).
- **Fortran**: column-major (first dimension varies fastest).

The Python script transposes before saving to binary:

```python
np_input = np_input.transpose().flatten()
```

`transpose()` reverses the index order from `[B, C, H, W]` to `[W, H, C, B]`.
When Fortran reads the flat binary and `reshape`s it into its own
`(B, C, H, W)` array, the elements fall into the expected positions.

For more detail, see the
[FTorch documentation on transposing arrays](https://cambridge-iccs.github.io/FTorch/page/usage/transposing.html).
