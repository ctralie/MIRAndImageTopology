MEX = mex
MEXINCLUDE = -I/usr/local/MATLAB/R2013b/extern/include/


#LIBS = -lcudart -lcublas

all: Persistence0D1D

Persistence0D1D: Persistence0D1D.cpp
	$(MEX) Persistence0D1D.cpp $(LIBS)

clean:
	rm -f Persistence0D1D *.o
