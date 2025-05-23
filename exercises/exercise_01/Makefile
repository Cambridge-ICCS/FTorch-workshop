# compiler
# Note - this should match the compiler that the library was built with
FC = gfortran

# Change this to the path where you installed ftorch
FTORCH_ROOT = </path/to/installation>

# compile flags
FCFLAGS = -O3 -I$(FTORCH_ROOT)/include/ftorch

# link flags (the -Wl,-rpath flag specifies where to find the shared library at runtime)
LDFLAGS = -L$(FTORCH_ROOT)/lib/ -lftorch -Wl,-rpath,$(FTORCH_ROOT)/lib

PROGRAM = simplenet_fortran
SRC = simplenet_fortran.f90
OBJECTS = $(SRC:.f90=.o)

all: $(PROGRAM)

$(PROGRAM): $(OBJECTS)
		$(FC) $(FCFLAGS) -o $@ $^ $(LDFLAGS)

%.o: %.f90
		$(FC) $(FCFLAGS) -c $<

clean:
		rm -f *.o *.mod $(PROGRAM)

