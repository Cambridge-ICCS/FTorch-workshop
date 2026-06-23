# Exercise 1 - SimpleNet

## Description

This example provides a simple but complete demonstration of how to use the
FTorch library.

A Python file `simplenet.py` is provided that defines a very simple PyTorch
'net' that takes an input vector of length 5 and applies a single `Linear` layer
to multiply it by 2.

We will use the FTorch `pt2ts` utility to save this simple net to TorchScript.
Then we will modify `simplenet_fortran.f90` to read in the torchscripted model
and run inference.

## Running

To run `simplenet.py`:
```
python3 simplenet.py
```
This defines the net and runs it with an input tensor [0.0, 1.0, 2.0, 3.0, 4.0] to produce the result:
```
Model output: tensor([[0., 2., 4., 6., 8.]])
```
A PyTorch model file `pytorch_simplenet_model_cpu.pt` and an input tensor file
`pytorch_simplenet_input_tensor_cpu.pt` will also be created.

To convert the SimpleNet model to TorchScript run the `pt2ts` command that
comes with FTorch:
```
pt2ts SimpleNet \
  --model_definition_file simplenet.py \
  --input_model_file pytorch_simplenet_model_cpu.pt \
  --output_model_file torchscript_simplenet_model_cpu.pt
```
This should produce `torchscript_simplenet_model_cpu.pt` - the TorchScript
instance of the net.

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
executable:
```
./simplenet_fortran
```

This runs the model with the array `[0.0, 1.0, 2.0, 3.0, 4.0]` and should produce the output:
```
 Model parameters:
_fwd_seq.0.weight:
  2  0  0  0  0
  0  2  0  0  0
  0  0  2  0  0
  0  0  0  2  0
  0  0  0  0  2
 [ CPUFloatType{5,5} ]
 Model output:
   0.00000000       2.00000000       4.00000000       6.00000000       8.00000000
```
If the test passes, you should also see:
```
SimpleNet example ran successfully
```
## Fortran tasks

### Task 1

```fortran
   ! TODO: Import our library for interfacing with PyTorch
```

#### Solution

<details>

```fortran
   ! Import our library for interfacing with PyTorch
   use ftorch, only : torch_model_print_parameters, torch_model, torch_tensor, &
                      torch_kCPU, torch_tensor_from_array, torch_model_load, &
                      torch_model_forward
```

Note that
```fortran
   use ftorch
```
would work, and may be useful for the purposes of getting familiar with the code in
the exercise.
However, this approach is the equivalent of `from module import *` in Python which is
considered bad practice as it pulls everything from the module into the namespace.
This can have unintended consequences and cause conflicts so it is better to explicitly
import only what you need.

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

### Task 4

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

### Task 5

```fortran
   ! TODO: Run inference on the model using `torch_model_forward`
```

#### Solution

<details>

```fortran
   ! Run inference on the model using `torch_model_forward`
   call torch_model_forward(torch_net, input_tensors, output_tensors)
```

</details>

---

## Further options

To explore the functionalities of this model:

- Try saving the model through tracing rather than scripting by modifying `pt2ts.py`
- Consider adapting the model definition in `simplenet.py` to function differently and
  then adapt the rest of the code to successfully couple your new model.
