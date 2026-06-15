# Exercise 2 - Real-world inference with ResNet-18

## Description

This exercise demonstrates a more realistic FTorch workflow using a pre-trained
ResNet-18 model from TorchVision to classify images.

The exercise has two stages:

1. **Single-image inference** - fill in the TODOs and run with `batch_size = 1`.
2. **Batching Extension** - add further images to the input data and run with
   larger batch sizes.

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

### 3. Verification with Python

Verify that the saved model can be read and used from Python by running:

```
python3 resnet_infer_python.py
```

to get a prediction for the dog image:
```
Image 0: Samoyed, probability 0.8846
```

### 3. Fortran inference

Build using CMake:

```
cmake -B build
cd build
cmake --build .

Run:

```
./resnet_infer_fortran ../torchscript_resnet18_model_cpu.pt
```

Expected output:
```
 Running inference with batch_size =            1
 Loaded input data from ../data/image_batch_1.dat
Image 1:
  Predicted: Samoyed, probability 0.8846
```

Before this works, however, you will need to complete the code to cast the Fortran
data to tensors, load a model, and run inference. Building on what you learnt in
exercise 1 complete the following tasks labelled as `TODO` comments in
`resnet_infer_fortran.f90`:

1. **Declare** `torch_model` and `torch_tensor` variables.
2. **Create tensors** from the Fortran arrays using
   `torch_tensor_from_array`. The arrays are 4D (`in_data(batch_size,3,224,224)`)
   and 2D (`out_data(batch_size,1000)`) with `batch_size = 1`.
3. **Load the model** using `torch_model_load`.
4. **Run inference** using `torch_model_forward`.
5. **Classify results** for each image in the batch using the `classify`
   subroutine.
6. **Clean up** using `torch_delete`.


## Stage 2: Add batching

### Generate a larger batch

In `generate_input_batch.py`, add `dog2.jpg` to the `image_files` list
to create a two-image batch. You can also download your own images, place
them in `data/`, and add them to the list to run batches of any size.

```
python3 generate_input_batch.py
```

### Run with the batch

```
./resnet_infer_fortran ../torchscript_resnet18_model_cpu.pt 2
```

### Verify in Python

```
python3 resnet_infer_python.py --batch_size 2
```

## Solution

If you become stuck See `resnet_infer_fortran_sol.f90` for a complete reference
solution.

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
