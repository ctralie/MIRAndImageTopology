//http://www.mathworks.com/help/matlab/matlab_external/debugging-c-c-language-mex-files.html
#include <mex.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <iostream>
#include <algorithm>
#include <vector>
#include <assert.h>
#include <map>
#include "matrix.h"

#define VERBOSE 0

using namespace std;

class Edge {
public:
	Edge(double w, int vp1, int vp2) {
		weight = w;
		v1 = vp1;
		v2 = vp2;
	}
	double weight;
	int v1, v2;
};

struct EdgeWeightComparator {
	bool operator()(Edge* e1, Edge* e2) const {
		if (e1->weight < e2->weight) {
			return true;
		}
		return false;
	}
};


void mexFunction(int nOutArray, mxArray *OutArray[], int nInArray, const mxArray *InArray[]) {  
	double* D;
	
	if (nInArray < 1) {
		mexErrMsgTxt("Distance Matrix Input Required");
		return;
	}
	
	const mwSize *dims;
	size_t rowsD, colsD;
	int ndim = mxGetNumberOfDimensions(InArray[0]);
	if (ndim != 2) {
		mexErrMsgTxt("Expecting 2D matrix as first input");
		return;
	}
	dims = mxGetDimensions(InArray[0]);
	rowsD = dims[0];
	colsD = dims[1];
	if (rowsD != colsD) {
		mexErrMsgTxt("Number of rows not equal to number of columns in distance matrix");
		return;
	}
	D = (double*)mxGetPr(InArray[0]);
	size_t N = rowsD;
	
	//Now setup output distance matrix (infinity everywhere except where edges are, and 
	//zero along diagonal)
	mwSize outdims[2];
	outdims[0] = N;
	outdims[1] = N;
	OutArray[0] = mxCreateNumericArray(2, outdims, mxDOUBLE_CLASS, mxREAL);
	//TODO: Make this sparse later
	double* DOut = (double*)mxGetPr(OutArray[0]);
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) {
			index = i*N + j;
			if (j == i)
				DOut[index] = 0;
			else
				DOut[index] = mxGetInf();
		}
	}
	
	//Store the IDs of the connected components
	int vertexComponents = new int[N];
	for (int i = 0; i < N; i++) {
		vertexComponents[i] = i;
	}	
	
	//Sort the edges in increasing order by weight and apply Prim's (or Kruskal's) algorithm
	//NOTE: I only look at the upper triangular portion of the matrix because
	//it is assumed to be symmetric
	vector<Edges*> edges;
	for (int i = 0; i < N; i++) {
		for (int j = i+1; j < N; j++) {
			Edge* e = new Edge(D[i*N]+j, i, j);
			edges.push_back(e);
		}
	}
	sort(edges->begin(), edges->end(), EdgeWeightComparator());
	int NEdges = 0;//Can terminate when N-1 edges have been added
	for (size_t i = 0; i < edges.size(); i++) {
		int v1 = edges[i]->v1;
		int v2 = edges[i]->v2;
		if (vertexComponents[v1] != vertexComponents[v2]) {
			//If these vertices are not yet part of the same connected
			//component, adding this edge will not create a cycle
			//TODO: Union these two components
			
		}
		
	}

	/*mwSize outdims[2];
	//Output 0D homology classes
	outdims[0] = classes0D.size();
	outdims[1] = 2;
	OutArray[0] = mxCreateNumericArray(2, outdims, mxDOUBLE_CLASS, mxREAL);
	double *I = (double*)mxGetPr(OutArray[0]);*/

	delete[] vertexComponents;
	for (size_t i = 0; i < edges.size(); i++) {
		delete edges[i];
	}
	edges.clear();
}
