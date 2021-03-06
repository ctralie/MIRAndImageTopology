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

#define VERBOSE 0
#define ADDFACES 0  //Whether or not to include faces between all triples of points

using namespace std;

class HomologyClass {
public:
	static int idCounter;
	int id;
	int level;
	double birthTime, deathTime;
	bool died;
	vector<void*> generators;
	
	HomologyClass(int l, double bT) {
		level = l;
		birthTime = bT;
		deathTime = bT;
		died = false;
		//Increment the ID for the homology class each time
		id = idCounter;
		idCounter++;
	}
	
	void kill(double dT) {
		deathTime = dT;
		died = true;
	}
	
	void addGenerator(void* generator) {
		generators.push_back(generator);
	}
	
	int getID() {
		return id;
	}
	
	void setID(int i) {
		id = i;
	}
	
	void PrintMex() {
		mexPrintf("Homology Class %i (Level %i, %i generators, Born at %g, Died", id, level, generators.size(), birthTime);
		if (died)
			mexPrintf(" At %g)\n", deathTime);
		else
			mexPrintf(" Never)\n");
	}
};
int HomologyClass::idCounter = 0;

class TDASimplex {
public:
	TDASimplex(double d, int l, int i) {
		dist = d;
		level = l;
		id = i;
		homologyClass = NULL;//The homology class associated with the birth of this simplex
	}
	
	TDASimplex(int l, int i) {
		level = l;
		id = i;
	}
	
	virtual void getSortedNeighbors(vector<TDASimplex*>* neighbors) {}
	virtual void PrintMex() {
		mexPrintf("TDASimplex Parent Class\n");
	}
	
	int getLevel() {	return level;	}
	int getID() {	return id;	}
	void setID(int i) {		id = i;	}
	double getDist() {	return dist;	}
	void setDist(double d) {	dist = d;	}
	void setHomologyClass(HomologyClass* c) { homologyClass = c; }
	HomologyClass* getHomologyClass() { return homologyClass; }

protected:
	int level;//The dimension of the simplex
	int id;//The order in the filtration
	double dist;//The "distance" at which the simplex is added
	HomologyClass* homologyClass;//The homology class born at this simplex
};


//Compare two TDASimplexs by their distance (ties broken by level to keep it a proper filtration)
struct TDA_DistComparator {
	bool operator()(TDASimplex* o1, TDASimplex* o2) const {
		if (o1->getDist() < o2->getDist()) {
			return true;
		}
		else if (o1->getDist() == o2->getDist()) {
			//Make sure to add the faces of a simplex before adding the simplex
			return o1->getLevel() < o2->getLevel();
		}
		return false;
	}
};

//Compare two TDASimplexs by ID (used to help keep the columns of the sparse matrix in order)
struct TDA_IDComparator {
	bool operator()(TDASimplex* o1, TDASimplex* o2) const {
		return o1->getID() < o2->getID();
	}
};

struct MemAddressComparator {
	bool operator()(const void* o1, const void* o2) const {
		return o1 < o2;
	}
};

//0D simplex
class TDAVertex: public TDASimplex {
public:
	int origIndex;//Used to keep track of the original placement in the distance matrix
	TDAVertex(double d, int i, int origIndex):TDASimplex(d, 0, i) {
		this->origIndex = origIndex;
	}
	
	
	virtual void getSortedNeighbors(vector<TDASimplex*>* neighbors) {}
	virtual void PrintMex() {
		mexPrintf("TDAVertex(%i): origIndex = %i, id = %i, dist = %g\n", level, origIndex, id, dist);
	}
};

//1D simplex
class TDAEdge: public TDASimplex {
public:
	TDAVertex *v1, *v2;
	TDAEdge(double d, int i, TDAVertex* v1, TDAVertex* v2):TDASimplex(d, 1, i) {
		this->v1 = v1;
		this->v2 = v2;
	}
	virtual void getSortedNeighbors(vector<TDASimplex*>* neighbors) {
		neighbors->clear();
		neighbors->push_back(v1);
		neighbors->push_back(v2);
		sort(neighbors->begin(), neighbors->end(), TDA_IDComparator());
	}
	virtual void PrintMex() {
		mexPrintf("TDAEdge(%i): id = %i, dist = %g, v1-id = %i, v2-id = %i\n", level, id, dist, v1->getID(), v2->getID());
	}
};

//2D simplex
class TDATri: public TDASimplex {
public:
	TDAEdge *e1, *e2, *e3;
	TDATri(int i, TDAEdge* e1, TDAEdge* e2, TDAEdge* e3):TDASimplex(2, i) {
		this->e1 = e1;
		this->e2 = e2;
		this->e3 = e3;
		//By default, a face gets added as soon as the last of its three edges has been added
		this->setDist( max( max(e1->getDist(), e2->getDist()), e3->getDist()) );
	}
	virtual void getSortedNeighbors(vector<TDASimplex*>* neighbors) {
		neighbors->clear();
		neighbors->push_back(e1);
		neighbors->push_back(e2);
		neighbors->push_back(e3);
		sort(neighbors->begin(), neighbors->end(), TDA_IDComparator());
	}
	virtual void PrintMex() {
		mexPrintf("TDATri(%i): id = %i, dist = %g, e1-id = %i(%g), e2-id = %i(%g), e3-id = %i(%g)\n", level, id, dist, e1->getID(), e1->getDist(), e2->getID(), e2->getDist(), e3->getID(), e3->getDist());
	}
};

//For debugging
void printMatrix(vector<TDASimplex*>* M, int N) {
	int* colPointers = new int[N];
	for (int i = 0; i < N; i++) {
		colPointers[i] = 0;
	}
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) {
			int elem = 0;
			if (colPointers[j] < M[j].size()) {
				if (i == M[j][colPointers[j]]->getID()) {
					elem = 1;
					colPointers[j]++;
				}
			}
			mexPrintf("%i ", elem);
		}
		mexPrintf("\n");
	}
	delete[] colPointers;
}

//For debugging
void printBothMatrices(vector<TDASimplex*>* B, vector<TDASimplex*>* R, int N, int columnStar) {
	int* colPointers = new int[N];
	int* colPointers2 = new int[N];
	for (int i = 0; i < N; i++) {
		colPointers[i] = 0;
		colPointers2[i] = 0;
	}
	for (int i = 0; i < N; i++) {
		if (i == columnStar)
			mexPrintf("* ");
		else
			mexPrintf("  ");
	}
	mexPrintf("   ");
	for (int i = 0; i < N; i++) {
		if (i == columnStar)
			mexPrintf("* ");
		else
			mexPrintf("  ");
	}
	mexPrintf("\n");
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) {
			int elem = 0;
			if (colPointers[j] < B[j].size()) {
				if (i == B[j][colPointers[j]]->getID()) {
					elem = 1;
					colPointers[j]++;
				}
			}
			mexPrintf("%i ", elem);
		}
		mexPrintf("   ");
		for (int j = 0; j < N; j++) {
			int elem = 0;
			if (colPointers2[j] < R[j].size()) {
				if (i == R[j][colPointers2[j]]->getID()) {
					elem = 1;
					colPointers2[j]++;
				}
			}
			mexPrintf("%i ", elem);
		}
		mexPrintf("\n");
	}
	delete[] colPointers;
}


//Do linear time addition of two sorted columns in the sparse matrix
//This method assumes that col1 and col2 are in sorted order by TDASimplex.id (the filtration)
void addColToColMod2(vector<TDASimplex*>& col1, vector<TDASimplex*>& col2) {
	int i1 = 0, i2 = 0;
	vector<TDASimplex*> out;
//	mexPrintf("\n\nAdding Columns Mod2\n");
//	for (size_t i = 0; i < col1.size(); i++) {
//		mexPrintf("%i ", col1[i]->getID());
//	}
//	mexPrintf("\n");
//	for (size_t i = 0; i < col2.size(); i++) {
//		mexPrintf("%i ", col2[i]->getID());
//	}
//	mexPrintf("\n");
	while (i1 < (int)col1.size() && i2 < (int)col2.size()) {
		int id1 = col1[i1]->getID();
		int id2 = col2[i2]->getID();
		if (id1 == id2) {
			i1++;
			i2++;
			//Do nothing; they cancel out mod2 if they are the same
		}
		else if (id1 < id2) {
			//Add the element from col1 first and move down one element on col1
			out.push_back(col1[i1]);
			i1++;
		}
		else if (id2 < id1) {
			//Add the element from col2 first and move down one element on col2
			out.push_back(col2[i2]);
			i2++;
		}
		if (i1 == (int)col1.size()) {
			//Add the rest of the elements from column 2 if I'm through column 1
			while (i2 < (int)col2.size()) {
				out.push_back(col2[i2]);
				i2++;
			}
		}
		if (i2 == (int)col2.size()) {
			//Add the rest of the elements from column 1 if I'm through column 2
			while (i1 < (int)col1.size()) {
				out.push_back(col1[i1]);
				i1++;
			}
		}
	}
	//Overwrite col2 with the result
	col2.clear();
	col2.insert(col2.begin(), out.begin(), out.end());
//	for (size_t i = 0; i < col2.size(); i++) {
//		mexPrintf("%i ", col2[i]->getID());
//	}
//	mexPrintf("\n\n");
}


//Add the column "col" to every subsequent column in B that contains the low 
//element of col in the matrix B (and do that in parallel with R)
//This method assumes that the columns of B and R are in sorted order by TDASimplex.id (the filtration)
void addLowElementToOthers(vector<TDASimplex*>* B, vector<TDASimplex*>* R, int col, int N, vector<int>&colsToSearch, int* startingIndices) {
	assert(col >= 0 && col < N);
	assert(B[col].size() > 0);
	TDASimplex* low = (B[col])[B[col].size()-1];//The low element is the last element in sorted order
	for (int i = startingIndices[col]+1; i < colsToSearch.size(); i++) {
		int j = colsToSearch[i];
		//Check to see if this column has the low element
		for (int k = 0; k < B[j].size(); k++) {
			if ((B[j])[k] == low) {
				//This column does contain the low element so add B[col] to it
				addColToColMod2(B[col], B[j]);
				addColToColMod2(R[col], R[j]);
				break;
			}
		}
	}
}

void doReduction(vector<TDASimplex*>& tdaObjs, vector<HomologyClass*>& homologyClasses) {
	int N = (int)tdaObjs.size();
	//Put the filtration in order and reset the IDs based on that order
	sort(tdaObjs.begin(), tdaObjs.end(), TDA_DistComparator());
	vector<int> simplexIndices[3];//Locations of columns of simplices by dimension
	int* startingIndices = new int[N];
	if (VERBOSE) {
		mexPrintf("===== TDA Objects Sorted =====\n");
	}
	for (int i = 0; i < N; i++) {
		tdaObjs[i]->setID(i);
		int level = tdaObjs[i]->getLevel();
		assert(level < 3);
		simplexIndices[level].push_back(i);
		startingIndices[i] = (int)simplexIndices[level].size() - 1;
		if (VERBOSE) {
			tdaObjs[i]->PrintMex();
		}
	}
	if (VERBOSE) {
		mexPrintf("\n\n");
	}
	
	
	//Initialize the sparse matrix structures in the co-reduction
	//Keep the vectors at each column in order by ID for efficient merging
	vector<TDASimplex*>* B = new vector<TDASimplex*>[tdaObjs.size()];//Boundary matrix that's reduced
	vector<TDASimplex*>* R = new vector<TDASimplex*>[tdaObjs.size()];//Identity matrix that's reduced in parallel
	for (int i = 0; i < N; i++) {
		R[i].push_back(tdaObjs[i]);
		tdaObjs[i]->getSortedNeighbors(&B[i]);
	}
	
	//Now add each object in the order of the filtration
	for (int i = 0; i < N; i++) {
		if (i % (N/20) == 0) {
			//Print a dot every 5% of progress in the reduction
			mexPrintf(".");
			mexEvalString("drawnow");
		}
		double dist = tdaObjs[i]->getDist();
		
		if (tdaObjs[i]->getLevel() == 0) {//A vertex is added
			//When a vertex is added a 0D homology class is automatically 
			//created with that vertex as a generator. Homology class is born at "dist"
			assert(B[i].size() == 0);
			HomologyClass* c = new HomologyClass(0, dist);
			c->addGenerator(tdaObjs[i]);
			tdaObjs[i]->setHomologyClass(c);
			homologyClasses.push_back(c);
		}
		else if (tdaObjs[i]->getLevel() == 1) {//An edge is added
			if (B[i].size() == 0) {
				//If it's a row of all zeros, add a 1D homology class born at "dist"
				//with the generators as the edges found in the coreduced matrix
				HomologyClass* c = new HomologyClass(1, dist);
				for (int k = 0; k < (int)R[i].size(); k++) {//Add the generators
					assert(R[i][k]->getLevel() == 1);
					TDAEdge* e = (TDAEdge*)R[i][k];
					c->addGenerator(e);
				}
				tdaObjs[i]->setHomologyClass(c);
				homologyClasses.push_back(c);
			}
			else {
				//Otherwise if a low element exists, kill the class associated with 
				//that element, and make the class of the low element the class 
				//of the high element
				assert(B[i].size() == 2);
				assert(B[i][0]->getLevel() == 0);
				assert(B[i][1]->getLevel() == 0);
				TDAVertex* v1 = (TDAVertex*)B[i][0];
				TDAVertex* v2 = (TDAVertex*)B[i][1];
				HomologyClass* c1 = (HomologyClass*)v1->getHomologyClass();
				HomologyClass* c2 = (HomologyClass*)v2->getHomologyClass();
				assert(c1 != NULL);
				assert(c2 != NULL);
				c2->kill(dist);//This class gets killed at "dist"
				v2->setHomologyClass(c1);
				//Also add this column to all other columns that contain the low element
				addLowElementToOthers(B, R, i, N, simplexIndices[1], startingIndices);
			}
		}
		else if (tdaObjs[i]->getLevel() == 2) {//A triangle face is added
			//If a low element exists, kill the homology class associated with that element
			//(there must be  one because the rank of boundary 2 is increasing by 1)
			//NOTE: Nothing is done if the column is all zeros, because I'm not keeping track
			//of 2D homology classes (yet)
			if (B[i].size() > 0) {
				TDASimplex* low = B[i][B[i].size()-1];
				assert(low->getLevel() == 1);
				TDATri* face = (TDATri*)tdaObjs[i];
				HomologyClass* c = low->getHomologyClass();
				c->kill(dist);//Kill the 1D homology class associated with the low edge
				//Also add this column to all other columns that contain the low element
				addLowElementToOthers(B, R, i, N, simplexIndices[2], startingIndices);
			}
		}
		else {
			cerr << "TDA objects are not supported at level " << tdaObjs[i]->getLevel() << endl;
		}
		
		//For debugging
		/*mexPrintf("After processing column %i dist %g", i, dist);
		if (tdaObjs[i]->getLevel() == 0) mexPrintf(" (Vertex)");
		else if (tdaObjs[i]->getLevel() == 1) mexPrintf(" (Edge)");
		else if (tdaObjs[i]->getLevel() == 2) mexPrintf(" (Face)");
		mexPrintf("\n\n");
		printBothMatrices(B, R, N, i);
		mexPrintf("\n\n");*/
		/*if (tdaObjs[i]->getLevel() == 0) mexPrintf("V");
		else if (tdaObjs[i]->getLevel() == 1) mexPrintf("E");
		else if (tdaObjs[i]->getLevel() == 2) mexPrintf("F");
		if (i % 90 == 0) { mexPrintf("\n"); mexEvalString("drawnow");}*/
		
	}//End of filtration loop
	delete[] startingIndices;
}

bool verticesAreOnEdge(TDAVertex* v1, TDAVertex* v2, TDAEdge* e) {
	return (v1 == e->v1 && v2 == e->v2) || (v1 == e->v2 && v2 == e->v1);
}

//Assumes c represents a 1D homology class
//Returns the generator as an ordered vertex list in "cycle"
//The elements of "cycle" hold the indices of the vertices involved in the cycle
//The value of the double pointed to by dist is equal to the total distance around the cycle
void extractCycleFromHomologyClass(vector<double>& cycle, double* dist, HomologyClass* c) {
	if (c->level != 1) {
		cerr << "Warning: Trying to extract cycle from homolgy class that is " << c->level << "D\n";
		return;
	}
	TDAVertex *startV, *lastV, *V;
	*dist = 0;
	map<TDAVertex*, vector<TDAEdge*> > vertexEdges;
	int minIndex = -1;
	for (int i = 0; i < (int)c->generators.size(); i++) {
		TDAEdge* e = (TDAEdge*)c->generators[i];
		vertexEdges[e->v1].push_back(e);
		vertexEdges[e->v2].push_back(e);
		*dist = *dist + e->getDist();
		if (e->v1->origIndex < minIndex || minIndex == -1) {
			minIndex = e->v1->origIndex;
			lastV = e->v1;
		}
		if (e->v2->origIndex < minIndex || minIndex == -1) {
			minIndex = e->v2->origIndex;
			lastV = e->v2;
		}
	}
	
	if (vertexEdges.begin()->second.size() != 2) {
		cerr << "Error: The first edge for a 1D homology class has a vertex with ";
		cerr << vertexEdges.begin()->second.size() << " incident edges\n";
		return;
	}
	//Traverse in the order of the first edge emanating from the first vertex
	//The first vertex has been chosen so that it is the one ordered the closest
	//to the beginning of the original list of vertices
	V = lastV;
	startV = lastV;
	cycle.push_back((double)(lastV->origIndex+1));
	while(true) {
		cycle.push_back((double)(V->origIndex+1));//Add 1 since Matlab is 1-indexed
		if (vertexEdges[V].size() != 2) {
			cerr << "Error: The generator for a 1D homology class has a vertex with ";
			cerr << vertexEdges[V].size() << " incident edges (there should be exactly 2)\n";
		}
		//Traverse the cycle to the next vertex
		TDAEdge* edge = vertexEdges[V][0];
		if (verticesAreOnEdge(V, lastV, edge)) {
			//Make sure I don't go back to an edge that's already been traversed
			edge = vertexEdges[V][1];
		}
		lastV = V;
		//Now go to the next vertex
		V = edge->v1;
		if (V == lastV) {
			V = edge->v2;
		}
		if (V == startV) {
			break;//Break once it's looped all the way around
		}
	}
	if (VERBOSE) {
		mexPrintf("Cycle found: ");
		for (int i = 0; i < cycle.size(); i++) {
			mexPrintf("%i ", (int)cycle[i]);
		}
		mexPrintf("\n");
	}
}


//Arguments: D (distance matrix), maxEdgeLength (optional)
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
	
	bool isMaxEdgeLength = false;
	double maxEdgeLength = 0;
	//A maximum edge length has been specified
	if (nInArray >= 2) {
		double* eLPtr = (double*)mxGetPr(InArray[1]);
		isMaxEdgeLength = true;
		maxEdgeLength = *eLPtr;
	}
	
	vector<TDASimplex*> tdaObjs;
	vector<HomologyClass*> homologyClasses;
	//NOTE: I only look at the upper triangular portion of the matrix because
	//it is assumed to be symmetric
	
	//Add the TDA vertices first
	for (size_t i = 0; i < N; i++) {
		TDAVertex* v = new TDAVertex(D[i*N+i], i, i);
		tdaObjs.push_back(v);
	}
	//Now add the edges
	map<int, TDAEdge* > tdaEdgeMap;//Store a map of the edges that are added
	//Index the map by N*i + j so that there is a unique ID for every edge (i, j)
	for (size_t i = 0; i < N; i++) {
		for (size_t j = i+1; j < N; j++) {
			double dist = D[j*N+i];
			if (isMaxEdgeLength && dist > maxEdgeLength)
				continue;
			TDAVertex* v1 = (TDAVertex*)tdaObjs[i];
			TDAVertex* v2 = (TDAVertex*)tdaObjs[j];
			TDAEdge* e = new TDAEdge(dist, -1, v1, v2);
			tdaObjs.push_back(e);
			tdaEdgeMap[N*i + j] = e;
		}
	}
	mexPrintf("%i edges added\n", tdaEdgeMap.size());
	//Now add the faces (Look between all sets of 3 points)
	if (ADDFACES) {
		for (size_t i = 0; i < N; i++) {
			for (size_t j = i+1; j < N; j++) {
				for (size_t k = j+1; k < N; k++) {
					//Only add faces along a set of 3 edges that have actually
					//been added
					if (tdaEdgeMap.find(i*N+j) == tdaEdgeMap.end())
						continue;
					if (tdaEdgeMap.find(j*N+k) == tdaEdgeMap.end())
						continue;
					if (tdaEdgeMap.find(i*N+k) == tdaEdgeMap.end())
						continue;
					//Edge i-j
					TDAEdge* e1 = tdaEdgeMap[i*N+j];
					//Edge j-k
					TDAEdge* e2 = tdaEdgeMap[j*N+k];
					//Edge i-k
					TDAEdge* e3 = tdaEdgeMap[i*N+k];
					TDATri* f = new TDATri(-1, e1, e2, e3);
					tdaObjs.push_back(f);
				}
			}
		}
	}
	
	mexPrintf("Beginning Reduction\n");
	doReduction(tdaObjs, homologyClasses);
	mexPrintf("Finished Reduction\n");
	mexEvalString("drawnow");
	vector<HomologyClass*> classes0D;
	vector<HomologyClass*> classes1D;
	if (VERBOSE) {
		mexPrintf("===== Homology Classes =====\n");
	}
	for (size_t i = 0; i < homologyClasses.size(); i++) {
		HomologyClass* c = homologyClasses[i];
		if (c->birthTime != c->deathTime || !c->died) { //Prune away all homology classes with birth time = death time
			if (c->level == 0) {
				classes0D.push_back(c);
			}
			else if (c->level == 1) {
				classes1D.push_back(c);
			}
			else {
				cerr << "Warning: Unsupported homology class at level " << c->level << endl;
			}
		}
		if (VERBOSE) {
			c->PrintMex();
		}
	}
	mexPrintf("\n\n");
	
	mwSize outdims[2];
	//Output 0D homology classes
	outdims[0] = classes0D.size();
	outdims[1] = 2;
	OutArray[0] = mxCreateNumericArray(2, outdims, mxDOUBLE_CLASS, mxREAL);
	double *I = (double*)mxGetPr(OutArray[0]);
	N = classes0D.size();
	for (size_t i = 0; i < N; i++) {
		I[i] = classes0D[i]->birthTime;
		if (classes0D[i]->died) {
			I[N+i] = classes0D[i]->deathTime;
		}
		else {
			I[N+i] = -1;//TODO: Better choice than -1 for death time for classes that never die
		}
	}
	
	//Output 1D homology classes
	outdims[0] = classes1D.size();
	outdims[1] = 2;
	OutArray[1] = mxCreateNumericArray(2, outdims, mxDOUBLE_CLASS, mxREAL);
	double *J = (double*)mxGetPr(OutArray[1]);
	N = classes1D.size();
	for (size_t i = 0; i < N; i++) {
		J[i] = classes1D[i]->birthTime;
		if (classes1D[i]->died) {
			J[N+i] = classes1D[i]->deathTime;
		}
		else {
			J[N+i] = -1;//TODO: Better choice than -1 for death time for classes that never die
		}
	}
	
	//Save generators in cell array
	outdims[0] = classes1D.size();
	outdims[1] = 1;
	OutArray[2] = mxCreateCellArray(2, outdims);
	mxArray* cellArrayPtr = OutArray[2];
	double* cycleDists = new double[classes1D.size()];
	for (int i = 0; i < (int)classes1D.size(); i++) {
		vector<double> cycle;
		extractCycleFromHomologyClass(cycle, &cycleDists[i], classes1D[i]);
		//Copy cycle over to an allocated matrix (note the explicit cast from vector<int> to int*)
		//mxArray* cyclePtr = mxCreateNumericArray(1, cycle.size(), mxINT32_CLASS, mxREAL);
		mxArray* cyclePtr = mxCreateDoubleMatrix(1, cycle.size(), mxREAL);
		double* cycleArray = mxGetPr(cyclePtr);
		memcpy(cycleArray, (double*)&cycle[0], cycle.size()*sizeof(double));
		//Place the matrix into the cell array
		mxSetCell(cellArrayPtr, i, cyclePtr);
		
		//Uncomment this to send over edges instead of vertices
		/*N = (int)classes1D[i]->generators.size();
		mxArray* cyclePtr = mxCreateDoubleMatrix(N, 2, mxREAL);
		double* cycleArray = mxGetPr(cyclePtr);
		for (int k = 0; k < N; k++) {
			TDAEdge* e = (TDAEdge*)classes1D[i]->generators[k];
			cycleArray[k] = (double)(e->v1->origIndex+1);
			cycleArray[N+k] = (double)(e->v2->origIndex+1);
		}
		//Place the matrix into the cell array
		mxSetCell(cellArrayPtr, i, cyclePtr);*/
	}
	
	OutArray[3] = mxCreateDoubleMatrix(1, classes1D.size(), mxREAL);
	double* cycleDistsArray = mxGetPr(OutArray[3]);
	memcpy(cycleDistsArray, cycleDists, classes1D.size()*sizeof(double));
	delete[] cycleDists;
	
	//Clear all memory from homology classes and TDA Objects
	for (size_t i = 0; i < homologyClasses.size(); i++) {
		delete homologyClasses[i];
	}
	for (size_t i = 0; i < tdaObjs.size(); i++) {
		delete tdaObjs[i];
	}
	mexPrintf("\n");//Put a line break after the progress dots
}
