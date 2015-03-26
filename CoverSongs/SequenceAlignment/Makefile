MEX = mex #Using matlab
#MEX = mkoctfile --mex#Using octave
#Change the path below to match your matlab path
MEXINCLUDE = -I/usr/local/MATLAB/R2014b/extern/include/


#LIBS = -lcudart -lcublas

all: getDTWDist swalignimp getEditDist

getDTWDist: getDTWDist.cpp
	$(MEX) -g getDTWDist.cpp $(MEXINCLUDE)

swalignimp: swalignimp.cpp
	$(MEX) -g swalignimp.cpp $(MEXINCLUDE)

getEditDist: getEditDist.cpp
	$(MEX) -g getEditDist.cpp $(MEXINCLUDE)

clean:
	rm -f *.mexa64
