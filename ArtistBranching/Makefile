MEX = mex
MEXINCLUDE = -I/usr/local/MATLAB/R2013b/extern/include/


#LIBS = -lcudart -lcublas

all: MST

Persistence0D1D: MST.cpp
	$(MEX) -g MST.cpp $(LIBS)

clean:
	rm -f MST *.o
