# Exercise 3 - Autograd

## Description

A Python demo is modified based on the one found in the PyTorch documentation as
`autograd.py`, which shows how to compute the gradient of an arithmetic
combination of Torch Tensors. There are several exercises to check that the
values are computed correctly.

The demo is replicated in Fortran as `autograd.f90`, to show how to do the same
thing using FTorch.

## Running

Run the Python version of the demo with
```
python3 autograd.py
```

To run the Fortran version of the demo we need to compile with (for example)
```
mkdir build
cd build
cmake .. -DCMAKE_PREFIX_PATH=<path/to/your/installation/of/library/> -DCMAKE_BUILD_TYPE=Release
cmake --build .
```

(Note that the Fortran compiler can be chosen explicitly with the `-DCMAKE_Fortran_COMPILER` flag,
and should match the compiler that was used to locally build FTorch.)

To run the compiled code, simply use
```
./autograd
```

## Fortran solutions

### Task 1

```fortran
  ! TODO: Initialise the tensor Q from the first array used for output with torch_tensor_from_array
```

<details>

```fortran
  ! Initialise Q from the first array used for output
  call torch_tensor_from_array(Q, out_data1, torch_kCPU)
```

</details>

### Task 2

```fortran
  ! TODO: Compute the same mathematical expression as in the Python example and print it to screen.
  !       Does it give the expected value?
```

<details>

```fortran
  ! Compute the same mathematical expression as in the Python example and print it to screen.
  Q = multiplier * (a**3 - b * b / divisor)
  write (*,*) "Q = 3 * (a^3 - b*b/3) = 3*a^3 - b^2 = ", out_data1(:)
```

The output should be
```
Q = 3 * (a^3 - b*b/3) = 3*a^3 - b^2 =   -12.0000000       65.0000000
```

</details>
