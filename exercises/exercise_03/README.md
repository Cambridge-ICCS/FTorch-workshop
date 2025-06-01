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

## Python tasks

### Task 1

```python
# TODO: Calculate the value of Q by hand to provide expected values
# Q_expected =
```

#### Solution

<details>

We have
$$Q = 3 (a^3 - b^2/3) = 3a^3 - b^2$$
Now
$$a=[2, 3] \implies a^3 = [8, 27]$$
and
$$b=[6, 4] \implies b^2 = [36, 16]$$
so
$$Q = 3 [8, 27] - [36, 16] = [24, 81] - [36, 16] = [-12, 65]$$

```python
# Calculate the value of Q by hand to provide expected values
Q_expected = torch.tensor([-12.0, 65.0])
```

</details>

### Task 2

```python
# TODO: Calculate the directional derivatives of Q with respect to a and b by hand to
#       provide expected values
# dQda_expected =
# dQdb_expected =
```

#### Solution

<details>

We have
$$Q = 3 (a^3 - b^2/3) = 3a^3 - b^2$$
so
$$\frac{\partial Q}{\partial a} = 9a^2$$
and
$$\frac{\partial Q}{\partial b} = -2b$$

In code:
```python
# Calculate the directional derivatives of Q with respect to a and b by hand to
# provide expected values
dQda_expected = 9 * a**2
dQdb_expected = -2 * b
```

</details>

## Fortran tasks

### Task 1

```fortran
  ! TODO: Initialise the tensor Q from the first array used for output with torch_tensor_from_array
```

#### Solution

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

#### Solution

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

### Task 3

```fortran
  ! TODO: Create tensors dQda and dQdb based off output arrays for the gradients with
  !       torch_tensor_from_array.
```

#### Solution

<details>

```fortran
  ! Create tensors dQda and dQdb based off output arrays for the gradients
  call torch_tensor_from_array(dQda, out_data2, torch_kCPU)
  call torch_tensor_from_array(dQdb, out_data3, torch_kCPU)
```

</details>

### Task 4

```fortran
  ! TODO: Retrieve the gradient values with torch_tensor_get_gradient and print the corresponding
  !       arrays to screen. Do they give the expected values?
```

#### Solution

<details>

```fortran
  ! Retrieve the gradient values and print the corresponding arrays to screen
  call torch_tensor_get_gradient(dQda, a)
  call torch_tensor_get_gradient(dQdb, b)
  write(*,*) "dQda = 9*a^2 = ", out_data2
  write(*,*) "dQdb = - 2*b = ", out_data3
```

The output should be
```
dQda = 9*a^2 =    36.0000000       81.0000000
dQdb = - 2*b =   -12.0000000      -8.00000000
```

</details>
