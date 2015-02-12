//Programmer: Chris Tralie
//Purpose: To implement the Morse Filtration on a 2D height function (image)
//using an efficient version of the Union Find algorithm with path compression
//and to return the 0D and 1D classes, with a representative loop for each class
#include <mex.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>
#include <assert.h>
#include <vector>
#include <set>
#include <algorithm>

using namespace std;

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

//Get the neighbors on a 2D grid
void getNeighbors(size_t idx, size_t N, size_t M, vector<size_t>& neighbs, bool eightNeighbors) {
	int u = (int)(idx%N);
	int v = (int)(idx/N);
	for (int du = -1; du <= 1; du++) {
		for (int dv = -1; dv <= 1; dv++) {
			if (du == 0 && dv == 0)
				continue;
			if (abs(du) == abs(dv) && !eightNeighbors)
				continue; //Ignore diagonals if not using eight neighbors
			if ((u+du) < 0 || (u+du) >= (int)N || (v+dv) < 0 || (v+dv) >= (int)M)
				continue; //Bounds check
			size_t idx = (size_t)(u+du) + N*((size_t)(v+dv));
			neighbs.push_back(idx);
		}
	}
}

//Debug function for boundary tracer
//Print out a binary matrix incidating the union find component that
//startPixel belongs to
void printBinaryImage(size_t* UFP, size_t startPixel, size_t N, size_t M) {
	mexPrintf("\n\n");
	size_t componentClass = UFFind(UFP, startPixel);
	mexPrintf("pixel = %i, componentClass = %i\n", startPixel, componentClass);
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < M; j++) {
			size_t idx = (size_t)i + N*((size_t)j);
			if (idx == startPixel) {
				if (UFFind(UFP, idx) == componentClass) {
					mexPrintf("* ");
				}
				else {
					mexPrintf("o ");
				}				
			}
			else {
				if (UFFind(UFP, idx) == componentClass) {
					mexPrintf("x ");
				}
				else {
					mexPrintf(". ");
				}
			}
		}
		mexPrintf("\n");
	}
	mexPrintf("\n\n");
}

//Return a loop that represents a homology class at the moment that it dies
void getGenerator(vector<size_t>& generator, size_t* UFP, size_t* BoundaryTraces, size_t startPixel, size_t N, size_t M) {
	//printBinaryImage(UFP, startPixel, N, M);
	size_t thisClass = UFFind(UFP, startPixel);
	generator.push_back(startPixel);
	BoundaryTraces[startPixel] = thisClass;
	while(true) {
		vector<size_t> neighbs;
		getNeighbors(*(generator.end()-1), N, M, neighbs, true);
		bool foundBoundaryPixel = false;
		for (size_t i = 0; i < neighbs.size(); i++) {
			if (BoundaryTraces[neighbs[i]] == thisClass) {
				continue;//Don't re-trace
			}
			if (UFFind(UFP, neighbs[i]) == thisClass) {
				//It is a potential boundary candidate, but make
				//sure it's actually on the boundary by checking
				//its neighboring pixels
				vector<size_t> n;
				getNeighbors(neighbs[i], N, M, n, true);
				bool boundaryPixel = false;
				if (n.size() < 8) {
					//This is is on the image boundary, so it is automatically part of the 
					//curve boundary
					boundaryPixel = true;
				}
				else {
					for (size_t k = 0; k < n.size() && !boundaryPixel; k++) {
						if (UFFind(UFP, n[k]) != thisClass) {
							boundaryPixel = true;
						}
					}
				}
				if (boundaryPixel) {
					foundBoundaryPixel = true;
					generator.push_back(neighbs[i]);
					BoundaryTraces[neighbs[i]] = thisClass;
					break;
				}
			}
		}
		if (!foundBoundaryPixel) {
			break;
		}
	}
}

//Arguments: D (distance matrix), eightNeighbors (1/0: optional)
void mexFunction(int nOutArray, mxArray *OutArray[], int nInArray, const mxArray *InArray[]) {
	bool returnGenerators = true;
	if (nOutArray > 1) {
		returnGenerators = true;
	}
	  
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
	
	//Optional parameter, whether or not to use eight neighbors
	bool eightNeighbors = false;
	if (nInArray >= 2) {
		dims = mxGetDimensions(InArray[1]);
		if (dims[0]*dims[1] > 0) {
			double* en = (double*)mxGetPr(InArray[1]);
			if (en[0] == 1) {
				eightNeighbors = true;
			}
		}
	}
	
	//***Step 1: Initialization
	//Find the sorted order of the points
	idxcmp cmp(D);
	size_t* idxorder = new size_t[NM];
	size_t* BoundaryTraces = new size_t[NM];
	for (size_t i = 0; i < NM; i++) {
		idxorder[i] = i;
		BoundaryTraces[i] = NM;
	}
	vector<size_t> idxv(idxorder, idxorder+NM);
	sort(idxv.begin(), idxv.end(), cmp);
	//The original index list points to the order in the sorted list
	for (size_t i = 0; i < NM; i++) {
		idxorder[idxv[i]] = i;
	}
	
	//Setup the union find data structure
	size_t* UFP = new size_t[NM];//Union find parent
	for (size_t i = 0; i < NM; i++) {
		UFP[i] = i;//Initially all nodes are root nodes (by convention their own parent)
	}
	
	//***Step 2: Filtration
	//Add points from bottom to top of image
	vector<BirthDeath> I;
	vector<vector<size_t> > generators;
	for (size_t i = 0; i < NM; i++) {
		size_t vCurr = idxv[i];
		vector<size_t> n;
		vector<size_t> neighbs;
		//Get list of neighbors
		getNeighbors(vCurr, N, M, n, eightNeighbors);
		for (size_t k = 0; k < n.size(); k++) {
			size_t repIdx = UFFind(UFP, n[k]);
			if (idxorder[repIdx] < i) {
				//Only consider neighbors that are already alive
				//Add the representative element
				neighbs.push_back(repIdx);
			}
		}
		//If none of this point's neighbors are alive yet, this point will become
		//alive with its own class
		if (neighbs.size() == 0) {
			continue;
		}
		
		//Find the unique neighbors
		//Otherwise, find the class that is the oldest
		set<size_t> neighbsUnique;
		size_t oldestNeighb = neighbs[0];
		for (size_t k = 0; k < neighbs.size(); k++) {
			if (idxorder[neighbs[k]] < idxorder[oldestNeighb]) {
				oldestNeighb = neighbs[k];
			}
			neighbsUnique.insert(neighbs[k]);
		}
		
		//Merge the earlier classes with the oldest class and
		//record them as a nontrivial class
		for (set<size_t>::iterator it = neighbsUnique.begin(); it != neighbsUnique.end(); it++) {
			if (*it != oldestNeighb) {
				BirthDeath bd;
				bd.birth = D[*it];
				bd.death = D[vCurr];
				I.push_back(bd);
				if (returnGenerators) {
					//TODO: Add index of union find representative as local min along with generator
					//Now find the generator associated with this class
					//Start with one of the pixels on the boundary of the class,
					//which is one of the neighbors of the pixel being added
					vector<size_t> generator;
					for (size_t k = 0; k < n.size(); k++) {
						if (UFFind(UFP, n[k]) == *it) {
							getGenerator(generator, UFP, BoundaryTraces, n[k], N, M);
							//mexPrintf("Found generator of size %i\n", generator.size());
							//By convention, the last element is the birthing index
							generator.push_back(UFFind(UFP, n[k]));
							generators.push_back(generator);
							break;
						}
					}
				}
			}
			UFUnion(UFP, D, oldestNeighb, *it);
		}
		
		//No matter what, the current pixel becomes part of the oldest
		//class it's connected to
		UFUnion(UFP, D, oldestNeighb, vCurr);
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
	
	if (returnGenerators) {
		//Save generators in cell array
		outdims[0] = I.size();
		outdims[1] = 1;
		OutArray[1] = mxCreateCellArray(2, outdims);
		mxArray* cellArrayPtr = OutArray[1];
		for (size_t i = 0; i < I.size(); i++) {
			mxArray* cyclePtr = mxCreateDoubleMatrix(1, generators[i].size(), mxREAL);
			double* cycleArray = mxGetPr(cyclePtr);
			for (size_t k = 0; k < generators[i].size(); k++) {
				cycleArray[k] = (double)generators[i][k];
			}
			//Place the matrix into the cell array
			mxSetCell(cellArrayPtr, i, cyclePtr);
		}		
	}
	
	delete[] BoundaryTraces;
	delete[] UFP;
	delete[] idxorder;
}

