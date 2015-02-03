//Programmer: Chris Tralie
//Purpose: To implement the Morse Filtration on a 2D height function (image)
//using the Union Find algorithm, and to return the 0D and 1D classes, with a 
//representative loop for each class
#include <mex.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>
#include <assert.h>
#include <vector>
#include <algorithm>

using namespace std;

//Whether or not to use all eight neighbors
#define EIGHTNEIGHBORS false

//Used to sort indices in order, given an array v
class idxcmp {
public:
	idxcmp(double* pv) {
		v = pv;
	}
	double* v;
	
	bool operator()(size_t a, size_t b) {
		return v[a] < v[b];
	}
};

typedef struct BD {
	double birth;
	double death;
} BirthDeath;

//Union find "find" with path-compression
size_t UFFind(size_t* UFP, size_t u) {
	if (UFP[u] != u) {
		return UFP[u] = UFFind(UFP, UFP[u]);
	}
	return u;
}

//Union find "union" with early birth-based merging
//(similar to rank-based merging...not sure if exactly the
//same theoretical running time)
void UFUnion(size_t* UFP, double* D, size_t u, size_t v) {
	//Go to the roots of each
	u = UFFind(UFP, u);
	v = UFFind(UFP, v);
	if (u == v) {
		return; //Already in union
	}
	//Merge the later birth at the root of the earlier birth
	size_t ufirst = u, usecond = v;
	if (D[v] < D[u]) {
		ufirst = v;
		usecond = u;
	}
	UFP[usecond] = ufirst;
}

//Arguments: D (distance matrix)
void mexFunction(int nOutArray, mxArray *OutArray[], int nInArray, const mxArray *InArray[]) {  
	double* D;
	if (nInArray < 1) {
		mexErrMsgTxt("Distance Matrix Input Required");
		return;
	}
	const mwSize *dims;
	size_t N, M, NM;
	int ndim = mxGetNumberOfDimensions(InArray[0]);
	if (ndim != 2) {
		mexErrMsgTxt("Expecting 2D matrix as input");
		return;
	}
	dims = mxGetDimensions(InArray[0]);
	N = dims[0];
	M = dims[1];
	NM = N*M;
	D = (double*)mxGetPr(InArray[0]);
	
	//***Step 1: Initialization
	//Find the sorted order of the points
	idxcmp cmp(D);
	size_t* idx = new size_t[NM];
	bool* dead = new bool[NM];
	for (size_t i = 0; i < NM; i++) {
		idx[i] = i;
		dead[i] = false;
	}
	vector<size_t> idxv(idx, idx+NM);
	sort(idxv.begin(), idxv.end(), cmp);
	
	//Setup the union find data structure
	size_t* UFP = new size_t[NM];//Union find parent
	for (size_t i = 0; i < NM; i++) {
		UFP[i] = i;//Initially all nodes are root nodes (by convention their own parent)
	}
	
	//***Step 2: Filtration
	//Add points from bottom to top of image
	vector<BirthDeath> I;
	for (size_t i = 0; i < NM; i++) {
		size_t vCurr = idxv[i];
		int u = (int)(vCurr%N);
		int v = (int)(vCurr/N);
		vector<int> neighbs;
		//List of neighbors (including the point itself)
		for (int du = -1; du <= 1; du++) {
			for (int dv = -1; dv <= 1; dv++) {
				if (du != 0 && abs(du) == abs(dv) && !EIGHTNEIGHBORS)
					continue; //Ignore diagonals if not using eight neighbors
				if ((u+du) < 0 || (u+du) >= (int)N || (v+dv) < 0 || (v+dv) >= (int)M)
					continue; //Bounds check
				size_t idx = (size_t)(u+du) + N*((size_t)(v+dv));
				size_t repIdx = UFFind(UFP, idx);
				if (D[repIdx] <= D[vCurr]) {
					//Only consider neighbors that are already alive
					neighbs.push_back(idx);
				}
			}
		}
		//If none of this point's neighbors are alive yet, don't worry about
		//merging anything
		if (neighbs.size() == 1)
			continue;
		
		//Otherwise, find the class that is the oldest
		double earlyBirth = D[neighbs[0]];
		double earlyIdx = neighbs[0];
		for (size_t k = 1; k < neighbs.size(); k++) {
			if (D[neighbs[k]] < earlyBirth) {
				earlyBirth = D[neighbs[k]];
				earlyIdx = neighbs[k];
			}
		}
		//Merge the earlier classes with the oldest class and
		//record them as a nontrivial class if their death time
		//is greater than their birth time
		for (size_t k = 0; k < neighbs.size(); k++) {
			if (neighbs[k] != earlyIdx) {
				size_t thisIdx = UFFind(UFP, neighbs[k]);
				if (D[thisIdx] < D[idxv[i]] && !dead[thisIdx]) {
					BirthDeath bd;
					bd.birth = D[thisIdx];
					bd.death = D[idxv[i]];
					I.push_back(bd);
					dead[thisIdx] = true;
				}
				UFUnion(UFP, D, earlyIdx, neighbs[k]);
			}
		}
	}
	//TODO: Immortal class?
	
	//***Step 3: Output results
	mwSize outdims[2];
	//Output 0D homology classes
	outdims[0] = I.size();
	outdims[1] = 2;
	OutArray[0] = mxCreateNumericArray(2, outdims, mxDOUBLE_CLASS, mxREAL);
	double *IOut = (double*)mxGetPr(OutArray[0]);
	for (size_t i = 0; i < I.size(); i++) {
		IOut[i] = I[i].birth;
		IOut[i+I.size()] = I[i].death;
	}
	
	delete[] UFP;
	delete[] dead;
	delete[] idx;
}
