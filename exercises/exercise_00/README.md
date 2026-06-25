## Exercise 0: Hello Fortran and PyTorch

This exercise will familiarise you with basic usage of Fortran and PyTorch.

### Hello PyTorch

Take a look at the `hello_pytorch.py` file and read through the comments in the
code, making sure that you understand what it does.

Then run the code as follows.
```sh
python hello_pytorch.py
```
Check that the output that it prints to screen is what you expect.

### Hello Fortran

Take a look at the `hello_fortran.f90` file and read through the comments in the
code, making sure that you understand what it does.

Now we will compile the code.
First create a build directory and generate build scripts for the Fortran code inside
using CMake:
```sh
mkdir build
cd build
cmake ..
```

We then use CMake again to build the executable:
```sh
cmake --build .
```

Note that `hello_fortran.f90` uses a module called `math_mod`, which is defined
in `math_mod.f90`. Both files are listed in `CMakeLists.txt` and built together
into an executable `hello_fortran`.

Run the executable with:
```sh
./hello_fortran
```
Check that the output that it prints to screen is what you expect.
