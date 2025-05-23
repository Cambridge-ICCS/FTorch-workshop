<img src="slides/ICCS_logo.png"  width="355" align="left">

<br><br><br><br><br><br><br>

# FTorch Workshop

![GitHub](https://img.shields.io/github/license/Cambridge-ICCS/FTorch-workshop)
[![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa]

This repository contains documentation, resources, and code for the a workshop
teaching use of the ICCS [FTorch library](https://github.com/Cambridge-ICCS/FTorch)
for coupling PyTorch models to Fortran code.
The session has been designed and delivered by
[Jack Atkinson](https://jackatkinson.net/) ([**@jatkinson1000**](https://github.com/jatkinson1000))
and has been taught at the
[ICCS](https://iccs.cam.ac.uk/events/institute-computing-climate-science-annual-summer-school-2024) 
summer schools.  
All materials are available such that individuals can cover the course in their own time.

## Contents

- [Learning Objectives](#learning-objectives)
- [Teaching material](#teaching-material)
- [Preparation and prerequisites](#preparation-and-prerequisites)
- [Installation and setup](#installation-and-setup)
- [License information](#license)
- [Contribution Guidelines and Support](#contribution-guidelines-and-support)


## Learning Objectives
The key learning objective from this workshop could be simply summarised as:  
_Provide the ability to couple PyTorch models to Fortran using FTorch_.

However, more specifically we aim to:

* provide a deeper understanding of Torch models and the libtorch library,
* introduce FTorch and it's aims and benefits,
* teach users the full pipeline of taking a PyTorch model and coupling it to a Fortran code,
* introduce the automatic differentiation aspects of FTorch, and
* highlight best practices and efficient use when doing the above.


## Teaching Material

### Slides
The slides for this workshop can be viewed on the ICCS Summer School Website:

- [Slides](https://cambridge-iccs.github.io/FTorch-workshop)

The slides are generated from markdown using quarto.
The raw markdown and html files can be found in the [slides](slides/) directory.

### Exercises
The exercises for the course can be found in the [exercises](exercises/) directory.

They consist of:

* Exercise 0: An introduction to Fortran and PyTorch to get up to speed
* Exercise 1: A walkthrough of how to take your net from PyTorch and use it in Fortran
* Exercise 2: A comparison of efficient and inefficient approaches to using FTorch as part
  of a larger numerical code
* Exercise 3: A demonstration of some of the automatic differentiation features of FTorch

Between exercises 0 and 1 we will also walk through building and installing FTorch,
details for which can be found in the slides and in the [`build_FTorch.sh`](build_FTorch.sh)
script.


## Prerequisites

To get the most out of the session we assume a basic understanding in a few areas and 
for you to do some preparation in advance.
Expected knowledge is outlined below, along with resources for reading
if you are unfamiliar.

### Python
The course uses some elements of Python and assumes some basic knowledge of the ecosystem.
This includes:
- use of a python virtual environment,
- installation of dependencies, and
- running python scripts from the command line.

### Machine Learning and PyTorch

Whilst we are using PyTorch and neural networks in this course we will not be teaching
any formal concepts.

- We recommend the [video series by 3Blue1Brown](https://www.3blue1brown.com/topics/neural-networks),
  at least chapters 1-3, for an awareness of high-level deep-learning concepts, though this
  is not essential.
- For an understanding of PyTorch we recommend the _Practical Machine Learning with PyTorch_
  workshop ([Atkinson and Denholm (2024)](https://jose.theoj.org/papers/10.21105/jose.00239))
  materials for which are available online at
  [github/Cambridge-ICCS/practical-ml-with-pytorch](https://github.com/Cambridge-ICCS/practical-ml-with-pytorch).

### Fortran

The key objective of this course is to call PyTorch code from within Fortran.
However, expert knowledge is not a prerequisite.
Rather, we will assume that you are comfortable reading Fortran code and familiar with
the basic concepts of the language (variables, subroutines, modules etc.)
To this end Fortran-Lang provide an [excellent quickstart tutorial](https://fortran-lang.org/learn/quickstart/).


## Preparation

### Using GitHub Codespaces

We suggest that participants follow along with the workshop by using a
[GitHub Codespace](https://github.com/features/codespaces) (GitHub login required).
This allows you to work in a VSCode Web session running code on from a container in
the cloud.
All GitHub users have a certain number of hours of credit for using codespaces.
This can be extended if you have GitHub Education.

To launch a codespace for the workshop navigate to the
[repository on Github](https://github.com/Cambridge-ICCS/FTorch-workshop) and click
the down arrow on the 'code button'.
Select 'Codespaces' and then 'Create codespace on main'.
This will open a new window and start up an interactive VSCode session.

Once the container is set up you will be dropped into a VSCode session with
dependencies (Python, gfortran, and CMake) installed, and a copy of the workshop
repository cloned.

> [!NOTE]  
> Firefox users with enhanced tracking protection will need to disable this for
> the codespace.

### Non-codespace participants

If you wish to follow this workshop on your own machine rather than using GitHub
codespaces please follow the instructions below.

In preparation for the course please ensure that your computer contains the following:
- A text editor
  e.g. vim/[neovim](https://neovim.io/), [gedit](https://gedit.en.softonic.com/), [vscode](https://code.visualstudio.com/), [sublimetext](https://www.sublimetext.com/) etc. to open and edit code files
- A terminal emulator
  e.g. [GNOME Terminal](https://help.gnome.org/users/gnome-terminal/stable/), [wezterm](https://wezfurlong.org/wezterm/index.html), [Windows Terminal (windows only)](https://learn.microsoft.com/en-us/windows/terminal/), [iTerm (mac only)](https://iterm2.com/)
- python virtual environment
  see [Installation and setup](#installation-and-setup)
- Fortran, C, and C++ compilers
  Unless you are familiar with other options we suggest using the [Gnu Compiler Collection (GCC)](https://gcc.gnu.org)
  This is freely available, and comes as standard on many systems or is available through
  all good package managers.
- CMake
  The [CMake build system](https://cmake.org/) is used for building FTorch. Similarly it is available
  online or through all good package managers.

> [!NOTE]  
> Note for Windows users: _We strongly advise using the
> [Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/en-us/windows/wsl/)
> for this workshop.
> If you wish to proceed on native Windows please follow the specific
> [FTorch guidance for Windows Users](https://cambridge-iccs.github.io/FTorch/page/troubleshooting.html#windows)
> to prepare a system.\
> We have linked suitable applications for Windows in the above lists, though you may wish
> to refer to [Windows' getting-started with python information](https://learn.microsoft.com/en-us/windows/python/beginners)
> for a complete guide to getting set up._

If you require assistance or further information with any of these please reach out to
us before a training session.

#### 1. Clone or fork the repository
Navigate to the location you want to install this repository on your system and clone
via https by running:
```
git clone https://github.com/Cambridge-ICCS/FTorch-workshop.git
```
This will create a directory `FTorch-workshop/` with the contents of this repository.

Please note that if you have a GitHub account and want to preserve any work you do
we suggest you first [fork the repository](https://github.com/Cambridge-ICCS/FTorch-workshop/fork) 
and then clone your fork.
This will allow you to push your changes and progress from the workshop back up to your
fork for future reference.

#### 2. Create a virtual environment
Before installing any Python packages it is important to first create a Python virtual environment.
This provides an insulated environment inside which we can install Python packages 
without polluting the operating system's Python environment.
```
python3 -m venv .venv
```
This will create a directory called `.venv/` containing software for the virtual environment.
To activate the environment run:
```
source .venv/bin/activate
```
You can now work on python from within this isolated environment, installing packages
as you wish without disturbing your base system environment.

When you have finished working on this project run:
```
deactivate
```
to deactivate the venv and return to the system python environment.

You can always boot back into the venv as you left it by running the activate command again.

#### 3. Install dependencies

It is now time to install the dependencies for our code, for example PyTorch.
The project has been packaged with a [`pyproject.toml`](pyproject.toml) so can be installed in one go.
From within the root directory in a active virtual environment run:
```
pip install .
```
This will download the relevant dependencies into the venv as well as setting up the
datasets that we will be using in the course.


## License

The code materials in this project are licensed under the [MIT License](LICENSE).

The teaching materials are licensed under a
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc-by-nc-sa].

[cc-by-nc-sa]: http://creativecommons.org/licenses/by-nc-sa/4.0/
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg

[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]

## Contribution Guidelines and Support

If you spot an issue with the materials please let us know by
[opening an issue](https://github.com/Cambridge-ICCS/FTorch-workshop/issues/new)
here on GitHub clearly describing the problem.

If you are able to fix an issue that you spot, or an
[existing open issue](https://github.com/Cambridge-ICCS/FTorch-workshop/issues)
please get in touch by commenting on the issue thread.

Contributions from the community are welcome.
To contribute back to the repository please first
[fork it](https://github.com/Cambridge-ICCS/FTorch-workshop/fork),
make the neccessary changes to fix the problem, and then open a pull request back to
this repository clerly describing the changes you have made.
We will then preform a review and merge once ready.

If you would like support using these materials, adapting them to your needs, or
delivering them please get in touch either via GitHub or via
[ICCS](https://github.com/Cambridge-ICCS).

