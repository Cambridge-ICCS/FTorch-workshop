# Example 6 - Autograd

## Description

A Python demo is modified based on the one found in the PyTorch documentation as
`autograd.py`, which shows how to compute the gradient of an arithmetic
combination of Torch Tensors. There are several exercises to check that the
values are computed correctly.

The demo is replicated in Fortran as `autograd.f90`, to show how to do the same
thing using FTorch.

## Running

To run this example install FTorch as described in the main documentation.
Then from this directory create a virtual environment and install the necessary
Python modules:
```
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

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
