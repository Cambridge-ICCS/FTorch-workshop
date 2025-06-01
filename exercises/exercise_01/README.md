# Example 1 - SimpleNet

## Description

This example provides a simple but complete demonstration of how to use the
FTorch library.

A Python file `simplenet.py` is provided that defines a very simple PyTorch
'net' that takes an input vector of length 5 and applies a single `Linear` layer
to multiply it by 2.

We will develop a utility script called `pt2ts.py` which will save this simple
net to TorchScript. Then we will modify `simplenet_fortran.f90` to read in the
torchscripted model and run inference.

## Running

To run `simplenet.py`:
```
python3 simplenet.py
```
This defines the net and runs it with an input tensor [0.0, 1.0, 2.0, 3.0, 4.0] to produce the result:
```
tensor([[0, 2, 4, 6, 8]])
```

To save the SimpleNet model to TorchScript we will first need to modify the
`pt2ts.py` file. See the Python Tasks below.

Once you have finished those tasks, come back here and run the following:
```
python3 pt2ts.py
```
which will generate `saved_model.pt` - the TorchScript instance of the net.

To call the saved SimpleNet model from Fortran we need to first modify the
template provided in `simplenet_fortran.f90`. See the Fortran Tasks below.


Once you have finished these tasks, come back here and try building your code
using the `CMakeLists.txt` provided.
```
mkdir build
cd build
cmake .. -DCMAKE_PREFIX_PATH=<path/to/your/installation/of/library/> -DCMAKE_BUILD_TYPE=Release
cmake --build .
```

(Note that the Fortran compiler can be chosen explicitly with the `-DCMAKE_Fortran_COMPILER` flag,
and should match the compiler that was used to locally build FTorch.)

To run the compiled code calling the saved SimpleNet TorchScript from Fortran run the
executable with an argument of the saved model file:
```
./simplenet_fortran
```

This runs the model with the array `[0.0, 1.0, 2.0, 3.0, 4.0]` should produce the output:
```
   0.00000000       2.00000000       4.00000000       6.00000000       8.00000000
```

## Python tasks

### Task 1

```python
# FPTLIB-TODO
# Add a module import with your model here:
```

#### Solution

<details>

```python
import simplenet
```

</details>

---

### Task 2

```python
# FPTLIB-TODO
# Load a pre-trained PyTorch model
# Insert code here to load your model as `trained_model`.
```

#### Solution

<details>

```python
trained_model = simplenet.SimpleNet()
```

</details>

---

### Task 3

```python
# FPTLIB-TODO
# Generate a dummy input Tensor `dummy_input` to the model of appropriate size.
```

#### Solution

<details>

```python
trained_model_dummy_input = torch.ones(5)
```

</details>

---

### Task 4

```python
# FPTLIB-TODO
# Run model for dummy inputs
```

#### Solution

<details>

```python
trained_model_dummy_outputs = trained_model(
    trained_model_dummy_input,
)
```

</details>

---

### Task 5

```python
# FPTLIB-TODO
# Set the name of the file you want to save the torchscript model to:
```

#### Solution

<details>

```python
saved_ts_filename = "saved_model.pt"
```

</details>

---

### Task 6

```python
# FPTLIB-TODO
# Scripting
```

#### Solution

<details>

```python
script_to_torchscript(trained_model, filename=saved_ts_filename)
```

</details>

---


## Fortran tasks

### Task 1

```fortran
   ! TODO: Import our library for interfacing with PyTorch
```

#### Solution

<details>

```fortran
   ! Import our library for interfacing with PyTorch
   use :: ftorch, only : &
        torch_kCPU, &
        torch_tensor_from_array, &
        torch_model_load, &
        torch_model_forward, &
        torch_delete, &
        torch_tensor, &
        torch_model
```

</details>

---

### Task 2

```fortran
   ! TODO: Set up Torch data structures
   ! The net, a vector of input tensors (in this case we only have one), and the output tensor
```

#### Solution

<details>

```fortran
   ! Set up Torch data structures
   ! The net, a vector of input tensors, and a vector of output tensors
   type(torch_tensor), dimension(1) :: input_tensors
   type(torch_tensor), dimension(1) :: output_tensors
   type(torch_model) :: torch_net
```

</details>

---

### Task 3

```fortran
   ! TODO: Set Torchscript model path
```

#### Solution

<details>

```fortran
   ! Set Torchscript model path
   character(len=128) :: model_torchscript_file = 'saved_model.pt'
```

</details>

---

### Task 4

```fortran
   ! TODO: Create Torch input/output tensors from the above arrays
```

#### Solution

<details>

```fortran
   ! Create Torch input/output tensors from the above arrays
   call torch_tensor_from_array(input_tensors(1), in_data, torch_kCPU)
   call torch_tensor_from_array(output_tensors(1), out_data, torch_kCPU)
```

</details>

---

### Task 5

```fortran
   ! TODO: Load ML model
```

#### Solution

<details>

```fortran
   ! Load ML model
   call torch_model_load(torch_net, model_torchscript_file, torch_kCPU)
```

</details>

---

### Task 6

```fortran
   ! TODO: Infer
```

#### Solution

<details>

```fortran
   ! Infer
   call torch_model_forward(torch_net, input_tensors, output_tensors)
```

</details>

---

### Task 7

```fortran
   ! TODO: Cleanup
```

#### Solution

<details>

```fortran
   ! Cleanup
   call torch_delete(input_tensors)
   call torch_delete(output_tensors)
   call torch_delete(torch_net)
```

</details>

---

## Further options

To explore the functionalities of this model:

- Try saving the model through tracing rather than scripting by modifying `pt2ts.py`
- Consider adapting the model definition in `simplenet.py` to function differently and
  then adapt the rest of the code to successfully couple your new model.
