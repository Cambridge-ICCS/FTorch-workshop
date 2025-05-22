# Exercise 01 `simplenet_fortran`

We will now try to build our first fortran application that calls a PyTorch Neural Net.

> [!WARNING]
> TODO: Finish writing instructions for modifying the python code

## Building `simplenet_fortran`

### Configure the Makefile

To compile the `simplenet_fortran` code, we first need to modify the `Makefile` provided in this directory.

1. Open the `Makefile` in a text editor.
2. Locate the line that sets the `FTORCH_ROOT` variable.
3. Change its value to:

    ```makefile
    FTORCH_ROOT = /workspaces/FTorch-workshop/FTorch_bin
    ```
    
    > [!NOTE] 
    > This is the location that our build script (`/workspaces/build_FTorch.sh`) installed FTorch into earlier when we ran it. 

4. Save the file and proceed with the build instructions.

### Build

After modifying the `Makefile` we can now build our `simplenet_fortran` example by running the following command in the terminal:

```bash
$ make
```

If we now try running our program, it should produce the following output:

```bash
$ ./simplenet_fortran 
   0.00000000       2.00000000       4.00000000       6.00000000       8.00000000
```