//Programmer: Chris Tralie
//Purpose: To implement patch match for fast 1D binary cross-similarity matrix construction
//Usage: NNF = patchMatch(Ds1, Ds2, NNFInit, DebiasRs, NIters, K, NNType)
//Ds1 and Ds2 are Nxd and Mxd matrices that hold the d-dimensional features
//NNFInit: An initially (random) nearest neighbor field (NOTE: Assumed to be one-indexed
//since it's passed from Matlab)
//DebiasRs: A random list of numbers in the range [-1, 1] to help with the debiasing stage
//NIters: Number of iterations
//K: Number of neighbors
//NNType: 1 for L1, 2 for L2
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

//Decay rate for debiasing stage
#define ALPHA 0.5

typedef struct nninf {
	int idx;
	double dist;
} NNInfo;

struct NNInfo_DistComparator {
	bool operator()(const NNInfo& s1, const NNInfo& s2) const {
		if (s1.dist < s2.dist) {
			return true;
		}
		return false;
	}
};


//Distance functions assume points are along the rows
double L1Dist(double* Ds1, double* Ds2, int N , int M, int d, int i, int j) {
	double D = 0.0;
	for (int k = 0; k < d; k++) {
		D = D + abs(Ds1[i+k*N] - Ds2[j+k*M]);
	}
	return D;
}

double L2Dist(double* Ds1, double* Ds2, int N, int M, int d, int i, int j) {
	double DSqr = 0.0;
	for (int k = 0; k < d; k++) {
		DSqr = DSqr + (Ds1[i+k*N] - Ds2[j+k*M])*(Ds1[i+k*N] - Ds2[j+k*M]);
	}
	return sqrt(DSqr);
}

//Inputs: Ds1: Nxd matrix of features
//Ds2: Mxd matrix of features
//NIters: Number of iterations to do
//K: Number of nearest neighbors to check
//NNType: Integer (1/2) for L1 or L2

//Outputs: 1) Distance (scalar)
//2) (N+1) x (M+1) dynamic programming matrix (Optional)
void mexFunction(int nOutArray, mxArray *OutArray[], int nInArray, const mxArray *InArray[]) {  
	//////////////////////////////////////////////////////////
	///////////////  INITIALIZE VARIABLES ////////////////////
	//////////////////////////////////////////////////////////
	const mwSize *dims;
	if (nInArray < 6) {
		mexErrMsgTxt("Error: Ds1, Ds2, NNFInit, NIters, K, NNType required\n");
		return;
	}
	//patchMatch(Ds1, Ds2, NNFInit, DebiasRs, NIters, K, NNType)
	dims = mxGetDimensions(InArray[0]);
	int N = (int)dims[0];
	int d = (int)dims[1];
	double* Ds1 = (double*)mxGetPr(InArray[0]);
	double* Ds2 = (double*)mxGetPr(InArray[1]);
	dims = mxGetDimensions(InArray[1]);
	int M = (int)dims[0];

	if ((int)dims[1] != d) {
		mexErrMsgTxt("Error: Ds1 and Ds2 must have features in same dimension");
		return;
	}
	
	int NIters = (int)(*mxGetPr(InArray[4]));
	int K = (int)(*mxGetPr(InArray[5]));
	int NNType = (int)(*mxGetPr(InArray[6]));	
	double* NNFInit = (double*)mxGetPr(InArray[2]);
	dims = mxGetDimensions(InArray[2]);
	if ((int)dims[0] != N) {
		mexErrMsgTxt("Error: Wrong dimension in the nearest neighbor initialization");
		return;
	}
	if ((int)dims[1] != K) {
		mexErrMsgTxt("Error: Wrong number of neighbors in nearest neighbor initialization");
		return;
	}
	double* DebiasRs = (double*)mxGetPr(InArray[3]);
	dims = mxGetDimensions(InArray[3]);
	if ((int)dims[0]*(int)dims[1] != N*NIters) {
		mexErrMsgTxt("Error: Number of debias random variables must be equal to the number of query points times the number of iterations");
		return;
	}
	
	//Setup pointer to nearest neighbor function
	double (*NNFunction)(double*, double*, int, int, int, int, int);
	if (NNType == 1) {
		NNFunction = &L1Dist;
	}
	else if (NNType == 2) {
		NNFunction = &L2Dist;
	}
	else {
		mexErrMsgTxt("Error: Only L1 and L2 distance supported right now");
		return;
	}

	//Initialize the distances in the random nearest neighbor field
	int* NNF = new int[N*K];
	double* DNNF = new double[N*K];
	int Queries = 0;
	for (int i = 0; i < N; i++) {
		for (int k = 0; k < K; k++) {
			int idx = i+k*N;
			NNF[idx] = (int)(NNFInit[idx] - 1);//Convert to zero-indexed
			DNNF[idx] = NNFunction(Ds1, Ds2, N, M, d, i, NNF[idx]);
		}
	}
	
	//Initialize temporary arrays that help update neighbors
	int NMaxDebias = (int)ceil(log(M)/log(1.0/ALPHA));
	int otherM;
	double maxD;
	//Preallocate vector lists storing new neighbors to save time
	std::vector<NNInfo> propArr(K*2);
	std::vector<NNInfo> debiasArr(K*(NMaxDebias+1));
	
	//////////////////////////////////////////////////////////
	///////////////  MAIN ALGORITHM //////////////////////////
	//////////////////////////////////////////////////////////
	
	for (int iter = 0; iter < NIters; iter++) {
		mexPrintf("Iteration %i...\n", iter);
		mexEvalString("drawnow");
		for (int i = 0; i < N; i++) {
			//Step 1: Propagate
			if (i > 0) {
				//Initialize distances
				maxD = 0.0;
				for (int k = 0; k < K; k++) {
					propArr[k].idx = NNF[i+k*N];
					propArr[k].dist = DNNF[i+k*N];
					if (propArr[k].dist > maxD) {
						maxD = propArr[k].dist;
					}
				}
				maxD = maxD*2;//Just to be safe
				for (int k = K; k < 2*K; k++) {
					propArr[k].idx = -1;
					propArr[k].dist = maxD;
				}
				//Check neighbors
				for (int k = 0; k < K; k++) {
					otherM = NNF[(i-1)+k*N] + 1;
					if (otherM >= 0 && otherM < M) {
						propArr[k+K].idx = otherM;
						propArr[k+K].dist = NNFunction(Ds1, Ds2, N, M, d, i, otherM);
						Queries++;
					}
				}
				//Figure out the new closest K neighbors
				sort(propArr.begin(), propArr.end(), NNInfo_DistComparator());
				for (int k = 0; k < K; k++) {
					NNF[i+k*N] = propArr[k].idx;
					DNNF[i+k*N] = propArr[k].dist;
				}
			}
			
			//Step 2: Random Search (Debias)
			double Ri = DebiasRs[i+iter*N]*M;
			int NR = floor(log(abs(Ri))/log(1.0/ALPHA));
			//Initialize distances
			maxD = 0.0;
			for (int k = 0; k < K; k++) {
				debiasArr[k].idx = NNF[i+k*N];
				debiasArr[k].dist = DNNF[i+k*N];
				if (debiasArr[k].dist > maxD) {
					maxD = debiasArr[k].dist;
				}
			}
			maxD = maxD*2;//Just to be safe
			for (int k = K; k < (NR+1)*K; k++) {
				debiasArr[k].idx = -1;
				debiasArr[k].dist = maxD;
			}
			//Check random neighbors
			for (int r = 0; r < NR; r++) {
				int dr = (int)floor(Ri*pow(ALPHA, r));
				for (int k = 0; k < K; k++) {
					otherM = NNF[i+k*N] + dr;
					if (otherM >= 0 && otherM < M) {
						debiasArr[K*(r+1)+k].idx = otherM;
						debiasArr[K*(r+1)+k].dist = NNFunction(Ds1, Ds2, N, M, d, i, otherM);						
						Queries++;
					}
				}
			}
			//Figure out the new closest k neighbors
			std::sort(debiasArr.begin(), debiasArr.begin() + (NR+1)*K, NNInfo_DistComparator());
			for (int k = 0; k < K; k++) {
				NNF[i+k*N] = debiasArr[k].idx;
				NNF[i+k*N] = debiasArr[k].dist;
			}
		}
	}
	
	///////////////MEX OUTPUTS/////////////////
	//Convert nearest neighbor field to 1-indexed double array
	double* NNFOut = new double[N*K];
	for (int i = 0; i < N*K; i++) {
		NNFOut[i] = (double)(NNF[i]+1);
	}
	
	mwSize outdims[2];
	outdims[0] = N;
	outdims[1] = K;
	OutArray[0] = mxCreateNumericArray(2, outdims, mxDOUBLE_CLASS, mxREAL);
	double* NNFOutPr = (double*)mxGetPr(OutArray[0]);
	memcpy(NNFOutPr, NNFOut, N*K*sizeof(double));
	
	//Copy the number of queries
	if (nOutArray > 1) {
		outdims[0] = 1;
		outdims[1] = 1;
		OutArray[1] = mxCreateNumericArray(2, outdims, mxDOUBLE_CLASS, mxREAL);
		double* QueriesOut = mxGetPr(OutArray[1]);
		*QueriesOut = (double)Queries;
	}
	
	///////////////CLEANUP/////////////////
	delete[] NNFOut;
	delete[] DNNF;
	delete[] NNF;
}
