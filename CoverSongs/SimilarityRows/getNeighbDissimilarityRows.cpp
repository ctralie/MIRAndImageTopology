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
	double* Means = new double[K*NWindows];
	
	//Keep track of mean of each feature dimension in a sliding window
	double* mean = new double[K];
	for (int i = 0; i < K; i++) {
		mean[i] = 0;
		//Initialize as the mean of the first window
		for (int j = 0; j < 2*Delta+1; j++) {
			mean[i] = mean[i] + X[i*N+j];
		}
		Means[i*NWindows] = mean[i]/((double)(2*Delta+1));
	}
	
	//Temporary variable for storing scaled sliding window
	double* Win = new double[(2*Delta+1)*K];
	for (int i = Delta; i <= N-Delta-1; i++) {
        int currIdx = i - Delta;
		if (currIdx > 0) {
			//Swap out the oldest value from the mean and swap in the newest one
			for (int k = 0; k < K; k++) {
				mean[k] = mean[k] - X[i-Delta-1 + k*N] + X[i+Delta + k*N];
				Means[currIdx+k*NWindows] = mean[k]/((double)(2*Delta+1));
			}
		}
		//Copy over window and subtract off mean
		for (int di = -Delta; di <= Delta; di++) {
			int widx = di + Delta;
			for (int k = 0; k < K; k++) {
				Win[widx + k*(2*Delta+1)] = X[i+di + k*N] - mean[k]/((double)(2*Delta+1));
			}
		}
		//Normalize each point to the unit hyper-sphere
	    for (int widx = 0; widx < 2*Delta+1; widx++) {
		    double norm = 0;
		    for (int k = 0; k < K; k++) {
			    norm += Win[widx + k*(2*Delta+1)]*Win[widx + k*(2*Delta+1)];
		    }
		    norm = sqrt(norm);
		    for (int k = 0; k < K; k++) {
			    Win[widx + k*(2*Delta+1)] /= norm;
		    }
	    }
        
        //Compute the distance from the middle point to all other
        //points and store it in the current column of DRows
        for (int widx = 0; widx < 2*Delta+1; widx++) {
            double dist = 0;
            double dK = 0;
            for (int k = 0; k < K; k++) {
                dK = Win[widx + k*(2*Delta+1)] - Win[Delta + k*(2*Delta+1)];
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
	
	if (nOutArray > 1) {
	    outdims[0] = NWindows;
	    outdims[1] = K;
	    OutArray[1] = mxCreateNumericArray(2, outdims, mxDOUBLE_CLASS, mxREAL);
	    double* MeansPr = (double*)mxGetPr(OutArray[1]);
	    memcpy(MeansPr, Means, NWindows*K*sizeof(double));
	}
	
	///////////////CLEANUP/////////////////
	delete[] mean;
	delete[] Win;
	delete[] DRows;
	delete[] Means;
}
