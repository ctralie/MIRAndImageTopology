//Programmer: Chris Tralie
//Purpose: To implement an implicit version of Smith-Waterman that works on
//a binary dissimilarity matrix
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

//Inputs: X (N x K) feature matrix, Delta (scalar)
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
		mexErrMsgTxt("Error: Delta curvature window too big for the signal size\n");
		return;
	}
	
	//Keep track of mean of each MFCC dimension in a sliding window
	double* mean = new double[K];
	for (int i = 0; i < K; i++) {
		mean[i] = 0;
		//Initialize as the mean of the first window
		for (int j = 0; j < 2*Delta+1; j++) {
			mean[i] = mean[i] + X[i*N+j];
		}
	}
	
	int NCurv = N-2*Delta;
	double* Curv = new double[NCurv];
	double* ContigDists = new double[NCurv];
	double* SkipDists = new double[NCurv];
	
	//Temporary variable for storing scaled sliding window
	double* Win = new double[(2*Delta+1)*K];
	for (int i = Delta; i <= N-Delta-1; i++) {
		int cidx = i-Delta;
		if (i > Delta) {
			//Swap out the oldest value from the mean and swap in the newest one
			for (int k = 0; k < K; k++) {
				mean[k] = mean[k] - X[i-Delta-1 + k*N] + X[i+Delta + k*N];
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
		//Compute the geodesic distance
		ContigDists[cidx] = 0.0;
		for (int widx = 0; widx < 2*Delta; widx++) {
			double distSqr = 0.0;
			for (int k = 0; k < K; k++) {
				double diff = Win[widx + k*(2*Delta+1)] - Win[widx+1 + k*(2*Delta+1)];
				distSqr += diff*diff;
			}
			ContigDists[cidx] += sqrt(distSqr);
		}
		//Compute the euclidean segment distance
		SkipDists[cidx] = 0.0;
		for (int k = 0; k < K; k++) {
			double diff = Win[k*(2+Delta+1)] - Win[2*Delta + k*(2+Delta+1)];
			SkipDists[cidx] += diff*diff;
		}
		SkipDists[cidx] = sqrt(SkipDists[cidx]);
		//The "curvature" is the ratio of the two
		if (SkipDists[cidx] > 0) {
			Curv[cidx] = ContigDists[cidx] / SkipDists[cidx];
		}
		else {
			Curv[cidx] = 1.0;
		}
	}
	
	///////////////MEX OUTPUTS/////////////////
	mwSize outdims[2];
	outdims[0] = NCurv;
	outdims[1] = 1;
	OutArray[0] = mxCreateNumericArray(2, outdims, mxDOUBLE_CLASS, mxREAL);
	double* CurvPr = (double*)mxGetPr(OutArray[0]);
	memcpy(CurvPr, Curv, NCurv*sizeof(double));
	
	if (nOutArray > 1) {
		OutArray[1] = mxCreateNumericArray(2, outdims, mxDOUBLE_CLASS, mxREAL);
		double* ContigDistsPr = (double*)mxGetPr(OutArray[1]);
		memcpy(ContigDistsPr, ContigDists, NCurv*sizeof(double));
	}
	
	if (nOutArray > 2) {
		OutArray[2] = mxCreateNumericArray(2, outdims, mxDOUBLE_CLASS, mxREAL);
		double* SkipDistsPr = (double*)mxGetPr(OutArray[2]);
		memcpy(SkipDistsPr, SkipDists, NCurv*sizeof(double));
	}
	
	///////////////CLEANUP/////////////////
	delete[] mean;
	delete[] Curv;
	delete[] ContigDists;
	delete[] SkipDists;
	delete[] Win;
}
