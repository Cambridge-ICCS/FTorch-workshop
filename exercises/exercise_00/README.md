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

Then compile and link the code as follows.
```sh
gfortran -c math_mod.f90 hello_fortran.f90
gfortran -o ftn_prog hello_fortran.o math_mod.o
```
Note that `hello_fortran.f90` uses a module called `math_mod`, which is defined
in `math_mod.f90`. The first command compiles these files into object files,
then the second command links them together to create an executable called
`ftn_prog`.

Run the executable with:
```sh
./ftn_prog
```
Check that the output that it prints to screen is what you expect.
