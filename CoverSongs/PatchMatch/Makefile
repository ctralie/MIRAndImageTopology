MEX = mex #Using matlab
#MEX = mkoctfile --mex#Using octave
#Change the path below to match your matlab path
MEXINCLUDE = -I/usr/local/MATLAB/R2014b/extern/include/


#LIBS = -lcudart -lcublas

all: patchMatch1DMEX

patchMatch1DMEX: patchMatch1DMEX.cpp
	$(MEX) -g patchMatch1DMEX.cpp $(MEXINCLUDE)

clean:
	rm -f *.mexa64
