#!/bin/bash
# ---
# Script to build and install FTorch into a codespace environment
# It should be run from the top of the repository.
# ---

# Set up a virtual environment an install necessary Python dependencies
#   We will specify the cpu-only version of PyTorch to match the codespace hardware
python3 -m venv .venv
source .venv/bin/activate
echo "source $(pwd)/.venv/bin/activate" >> $HOME/.bashrc
pip install torch --index-url https://download.pytorch.org/whl/cpu
pip install numpy

# Clone FTorch and move to the directory
git clone https://github.com/Cambridge-ICCS/FTorch.git
cd FTorch

# Create a build directory to build FTorch in using CMake
mkdir build
cd build

# Extract the location of the installed packages in the venv
# This is typically `FTorch/build/venv/lib/python3.xx/site-packages/`
PYTHON_PATH=$(python -c "import sysconfig; print(sysconfig.get_path('purelib'))")

# Build FTorch using CMake
#   We will build in `Release`, linking to the libtorch installed in the virtual
#   environment, and installing the final library into FTorch-workshop/FTorch_bin/
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="$PYTHON_PATH"/torch \
  -DCMAKE_INSTALL_PREFIX=/workspaces/FTorch-workshop/FTorch_bin
cmake --build . --target install

# Add LibTorch libraries to the paths to be searched for dynamic linking at runtime
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PYTHON_PATH/torch/lib

# Add these commands to the .bashrc for future use
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$PYTHON_PATH/torch/lib" >> $HOME/.bashrc
echo "run the following command to setup your environment:"
echo "source \$HOME/.bashrc"

# Return user to the root of the workshop, leaving the venv activated
cd
