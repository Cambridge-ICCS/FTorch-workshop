# Exercise 2 - Real-world inference with ResNet-18

## Description

This exercise demonstrates a more realistic FTorch workflow using a pre-trained
ResNet-18 model from TorchVision to classify an image of a Samoyed dog.

You will:

- Work with a **real-world** pre-trained model (not a toy example).
- Explore **batching** — processing multiple images in a single forward pass.
- Follow the **full Python-to-Fortran pipeline**: define the model in Python,
  convert to TorchScript, then call from Fortran.

The model takes a 4-dimensional input tensor with shape `(batch, channels, height, width)`.
Handling this multidimensional data requires care with memory layout — see
[A note on data layout](#a-note-on-data-layout).

## The pipeline

There are three stages to this exercise:

1. **Python**: Run `resnet18.py` to download the pre-trained ResNet-18,
   preprocess an example image (`data/dog.jpg`), and save the model and input
   data.
2. **Convert**: Use the `pt2ts` command to convert the PyTorch model to
   TorchScript.
3. **Fortran**: Write Fortran code using FTorch to load the TorchScript model
   and run inference.

## Running

### 1. Python model

Run the Python script to download ResNet-18, preprocess the example image,
and save the model and input data:

```
python3 resnet18.py
```

This will produce:
- `pytorch_resnet18_model_cpu.pt` — the PyTorch model (state dict).
- `data/image_tensor.dat` — the preprocessed image as a binary tensor.
- The expected output:
```
Top prediction: class 258, probability = 0.884623
Input batch included 1 image(s).
```

#### Python task: Implement batching

Look at the `# TODO` comment in `resnet18.py`. Currently the script processes
a single image. Modify it to:

1. Load a second image (you can download one or copy the existing one).
2. Preprocess it with `preprocess_image()`.
3. Stack the two image tensors into a batch with `torch.stack()`.
4. Confirm the output says `Input batch included 2 image(s)`.

### 2. Convert to TorchScript

The `pt2ts` command-line tool converts a PyTorch model to TorchScript for use
from Fortran. Run:

```
pt2ts ResNet18 \
  --model_definition_file resnet18.py \
  --input_model_file pytorch_resnet18_model_cpu.pt \
  --output_model_file torchscript_resnet18_model_cpu.pt \
  --input_tensor_file data/image_tensor.dat \
  --test
```

This generates `torchscript_resnet18_model_cpu.pt` and performs a quick sanity
check.

Note that `pt2ts` works with pre-trained models just as it does with custom
ones — it only needs the model definition and the trained weights.

(Later, if you modified `resnet18.py` to use a batch size other than 1, you
will need to re-run both the Python script and `pt2ts` to regenerate the
data and TorchScript model with the matching batch size.)

### 3. Fortran inference

Build the Fortran code using CMake:

```
cmake -B build
cd build
cmake --build .
```

Run the compiled executable with the path to the TorchScript model:

```
./resnet_infer_fortran ../torchscript_resnet18_model_cpu.pt
```

Expected output:
```
 Top result:
 Samoyed (id= 258 ), probability =  0.884623706
```

#### Fortran tasks

The file `resnet_infer_fortran.f90` contains a skeleton with `! TODO` comments.
Fill them in to complete the inference pipeline:

1. **Import the `ftorch` module** (and the types and procedures you need).
2. **Declare** a `torch_model` and `torch_tensor` variables.
3. **Create tensors** from the Fortran arrays using `torch_tensor_from_array`.
4. **Load the model** using `torch_model_load`.
5. **Run inference** using `torch_model_forward`.
6. **Clean up** using `torch_delete` and `deallocate`.

For a complete reference, see `resnet_infer_fortran_sol.f90`.

#### Batching in Fortran

The batch size is controlled by the first element of `in_shape` in the Fortran
code:

```fortran
integer, parameter :: in_shape(in_dims) = [1, 3, 224, 224]
```

If you changed the Python script to process multiple images, update this value
to match your batch size, rebuild, and re-run. The output tensor also needs a
matching first dimension.

### Verification with Python

You can also verify the TorchScript model works correctly in Python before
moving to Fortran:

```
python3 resnet_infer_python.py
```

This loads the saved TorchScript model and runs inference, printing the top
prediction.

## A note on data layout

The input image is a 4-dimensional tensor with shape `(1, 3, 224, 224)` (batch,
colour channels, height, width). However, Python (C) and Fortran store
multidimensional arrays in opposite memory order:

- **C / Python**: row-major — the last dimension changes fastest.
- **Fortran**: column-major — the first dimension changes fastest.

To ensure the data is laid out correctly in memory for Fortran, the Python
script transposes the tensor before saving to binary:

```python
np_input = np.array(input_batch.numpy().transpose().flatten(), dtype=np_precision)
```

`transpose()` reverses the index order from `[B, C, H, W]` to `[W, H, C, B]`.
When Fortran then reads the flat binary and `reshape`s it into its own `[B, C, H, W]`
array, the elements fall into the expected positions.

(Note that `torch_tensor_from_array` performs a further internal transpose
as required for correct interaction with the model.)

For a more detailed discussion, see the FTorch documentation on
[when to transpose arrays](https://cambridge-iccs.github.io/FTorch/page/usage/transposing.html).
