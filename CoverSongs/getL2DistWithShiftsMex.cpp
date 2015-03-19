//Programmer: Chris Tralie
//Purpose: To create a flexible L2 metric between two images that matches each pixel to the closest pixel
//in a [-Delta, Delta] x [-Delta, Delta] window centered at that pixel
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

//Inputs: D1 (N x N): Distance Matrix, D2 (N x N) Distance Matrix
//Delta: (Scalar) how far to go on either side of each point
void mexFunction(int nOutArray, mxArray *OutArray[], int nInArray, const mxArray *InArray[]) {  
	///////////////MEX INPUTS/////////////////
	const mwSize *dims;
	if (nInArray < 3) {
		mexErrMsgTxt("Error: Two distance matrices and Delta required\n");
		return;
	}
	dims = mxGetDimensions(InArray[0]);
	int N = (int)dims[0];
	if ((int)dims[1] != N) {
	    mexErrMsgTxt("Error: Distance matrix should be square\n");
	    return;
	}
	double* D1 = (double*)mxGetPr(InArray[0]);
	dims = mxGetDimensions(InArray[1]);
	if ((int)dims[0] != N || (int)dims[1] != N) {
	    mexErrMsgTxt("Error: Distance matrices must be the same size\n");
	    return;
	}
	double* D2 = (double*)mxGetPr(InArray[1]);
	int Delta = (int)*((double*)mxGetPr(InArray[2]));
	if (2*Delta+1 > N) {
		mexErrMsgTxt("Error: Delta window too big for the signal size\n");
		return;
	}
	
    double diff = 0.0;
    for (int i = 0; i < N; i++) { 
        for (int j = 0; j < N; j++) {
            double minDiffSqr = D1[i*N+j] - D2[i*N+j];
            minDiffSqr = minDiffSqr*minDiffSqr;
            for (int di = -Delta; di <= Delta; di++) {
                int thisi = i + di;
                if (thisi < 0 || thisi >= N) {
                    continue;
                }
                for (int dj = -Delta; dj <= Delta; dj++) {
                    int thisj = j + dj;
                    if (thisj < 0 || thisj >= N) {
                        continue;
                    }
                    double thisDiffSqr = D1[thisi*N+thisj] - D2[thisi*N+thisj];
                    minDiffSqr = min(minDiffSqr, thisDiffSqr*thisDiffSqr);
                }
            }
            diff = diff + minDiffSqr;
        }
    }    
	diff = sqrt(diff);
	
	///////////////MEX OUTPUTS/////////////////
	mwSize outdims[2];
	outdims[0] = 1;
	outdims[1] = 1;
	OutArray[0] = mxCreateNumericArray(2, outdims, mxDOUBLE_CLASS, mxREAL);
	double* diffPr = (double*)mxGetPr(OutArray[0]);
	memcpy(diffPr, &diff, sizeof(double));
}
