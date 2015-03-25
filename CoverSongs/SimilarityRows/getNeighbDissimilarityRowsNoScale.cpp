//Programmer: Chris Tralie
//Purpose: To provide a skewed version of a distance matrix, where
//each column stores distances to points Delta before and Delta after
//the corresponding point in time
#include <mex.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <iostream>
#include <algorithm>
#include <queue>
#include <list>
#include <vector>
#include <assert.h>

using namespace std;

//Inputs: X (N x k): Feature Matrix
//Delta: (Scalar) how far to go on either side of each point
void mexFunction(int nOutArray, mxArray *OutArray[], int nInArray, const mxArray *InArray[]) {  
	///////////////MEX INPUTS/////////////////
	const mwSize *dims;
	if (nInArray < 2) {
		mexErrMsgTxt("Error: Feature matrix and Delta required\n");
		return;
	}
	dims = mxGetDimensions(InArray[0]);
	int N = (int)dims[0];
	int K = (int)dims[1];
	double* X = (double*)mxGetPr(InArray[0]);
	int Delta = (int)*((double*)mxGetPr(InArray[1]));
	
	if (2*Delta+1 > N) {
		mexErrMsgTxt("Error: Delta window too big for the signal size\n");
		return;
	}
	int NWindows = N-2*Delta;
	double* DRows = new double[(2*Delta+1)*NWindows];
	
	for (int i = Delta; i <= N-Delta-1; i++) {
        int currIdx = i - Delta;
        
        //Compute the distance from the middle point to all other
        //points and store it in the current column of DRows
        for (int widx = 0; widx < 2*Delta+1; widx++) {
            double dist = 0;
            double dK = 0;
            for (int k = 0; k < K; k++) {
                dK = X[widx + currIdx + k*N] - X[i + k*N];
                dist += dK*dK;
            }
            DRows[currIdx + widx*NWindows] = sqrt(dist);
        }
	}
	
	///////////////MEX OUTPUTS/////////////////
	mwSize outdims[2];
	outdims[0] = NWindows;
	outdims[1] = 2*Delta+1;
	OutArray[0] = mxCreateNumericArray(2, outdims, mxDOUBLE_CLASS, mxREAL);
	double* DRowsPr = (double*)mxGetPr(OutArray[0]);
	memcpy(DRowsPr, DRows, NWindows*(2*Delta+1)*sizeof(double));
	
	///////////////CLEANUP/////////////////
	delete[] DRows;
}
