//Programmer: Chris Tralie
//Purpose: To implement Dynamic Time Warping given a rectangular dissimilarity matrix
//TODO: Add Sakoe-Chiba constraints to speed up to linear
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

//Inputs: D (a binary N x M dissimilarity matrix)
//Outputs: 1) Distance (scalar)
//2) (N+1) x (M+1) dynamic programming matrix (Optional)
void mexFunction(int nOutArray, mxArray *OutArray[], int nInArray, const mxArray *InArray[]) {  
	///////////////MEX INPUTS/////////////////
	const mwSize *dims;
	if (nInArray < 1) {
		mexErrMsgTxt("Error: Dissimilarity matrix required\n");
		return;
	}
	dims = mxGetDimensions(InArray[0]);
	int N = (int)dims[0]+1;
	int M = (int)dims[1]+1;
	double* S = (double*)mxGetPr(InArray[0]);
	double maxDist = 0.0;
	for (int i = 0; i < N-1; i++) {
	    for (int j = 0; j < M-1; j++) {
	        if (S[i+j*(N-1)] > maxDist) {
	            maxDist = S[i+j*(N-1)];
	        }
	    }
	}
	
	double* D = new double[N*M];
	D[0] = 0.0;
	for (int i = 1; i < N; i++) {
		D[i] = maxDist;
	}
	for (int i = 1; i < M; i++) {
		D[i*N] = maxDist;
	}

	double maxD = 0;
	///////////////ALGORITHM/////////////////
	for (int i = 1; i < N; i++) {
		for (int j = 1; j < M; j++) {
		    D[i + j*N] = S[i-1 + (j-1)*(N-1)] + min(D[i-1 + j*N], min( D[i + (j-1)*N], D[i-1 + (j-1)*N] ) );
		}
	}
	
	///////////////MEX OUTPUTS/////////////////
	mwSize outdims[2];
	outdims[0] = 1;
	outdims[1] = 1;
	OutArray[0] = mxCreateNumericArray(2, outdims, mxDOUBLE_CLASS, mxREAL);
	double* dist = (double*)mxGetPr(OutArray[0]);
	*dist = D[N-1 + (M-1)*N];
	
	if (nOutArray > 1) {
		outdims[0] = N;
		outdims[1] = M;
		OutArray[1] = mxCreateNumericArray(2, outdims, mxDOUBLE_CLASS, mxREAL);
		double* DOut = mxGetPr(OutArray[1]);
		memcpy(DOut, D, N*M*sizeof(double));
	}
	
	///////////////CLEANUP/////////////////
	delete[] D;
}
