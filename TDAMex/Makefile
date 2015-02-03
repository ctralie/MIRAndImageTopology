MEX = mex
MEXINCLUDE = -I/usr/local/MATLAB/R2014b/extern/include/


#LIBS = -lcudart -lcublas

all: morseFiltration2DMex Persistence0D1D

morseFiltration2DMex: morseFiltration2DMex.cpp
	$(MEX) -g morseFiltration2DMex.cpp $(LIBS)

Persistence0D1D: Persistence0D1D.cpp
	$(MEX) -g Persistence0D1D.cpp $(LIBS)

clean:
	rm -f Persistence0D1D *.o
