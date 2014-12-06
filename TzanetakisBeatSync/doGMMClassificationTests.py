import numpy as np
from sklearn import mixture
from sys import argv, exit
import scipy.io as sio
import time
import pickle
import os

NCENTERS = 1
GENRES = ['blues', 'classical', 'country', 'disco', 'hiphop', 'jazz', 'metal', 'pop', 'reggae', 'rock']
NGENRES = len(GENRES)

SEEDVAL = 100
np.random.seed(SEEDVAL)

if __name__ == '__main__':
	genreModels = [None]*NGENRES
	genreModelsMFCC = [None]*NGENRES
	
	data = sio.loadmat('D.mat');
	
	#Confusion matrix
	C = np.zeros((NGENRES, NGENRES))
	
	#Shuffle data
	idx = np.arange(1000)
	for ii in range(10):
		idx[ii*100:(ii+1)*100] = idx[ii*100 + np.random.permutation(100)]
	
	songCoeffs = []
	for ii in range(1000):
		X = data['Alphas'][:, data['idxranges'][0][ii].flatten() - 1]
		X = X.toarray()
		songCoeffs.append(X)
	
	for fold in range(10):
		testidx = []
		for ii in range(NGENRES):
			testidx = testidx + [ii*100 + fold*10 + x for x in range(10)]
		testidx = np.array(testidx)
		trainidx = np.arange(1000)
		trainidx[testidx] = -1
		trainidx = trainidx[trainidx != -1]
		testidx = idx[testidx]
		trainidx = idx[trainidx]
		
		#Make GMMs for each genre
		for i in range(NGENRES):
			#Fit beats GMM
			g = None
			filename = "CachedGMMs/%s%i_%i.pk"%(GENRES[i], fold, NCENTERS)
			if os.path.exists(filename):
				g = pickle.load( open(filename, "rb") )
				print "Loading precomputed beats GMM for " + GENRES[i] + " fold %i"%fold
			else:
				g = mixture.GMM(n_components = NCENTERS)
				print "Fitting beats GMM for " + GENRES[i] + " fold %i..."%fold
				
				thisidx = trainidx[i*90 + np.arange(90)]
				X = np.array([])
				for song in thisidx:
					if X.shape[0] == 0:
						X = songCoeffs[song]
					else:
						X = np.concatenate( (X, songCoeffs[song]), 1)
				X = X.T
				
				tic = time.time()
				g.fit(X)
				toc = time.time() - tic
				print "Finished beats fitting GMM: Elapsed %g seconds"%toc
				#Cache genre model
				pickle.dump( g, open(filename, "wb") )
			genreModels[i] = g
	
		#Now read in each test file and apply to GMM
		for song in testidx:
			X = songCoeffs[song].T
			lhoods = np.zeros(NGENRES)
			#Try out the model from each genre
			for i in range(NGENRES):
				lhoods[i] = np.mean(genreModels[i].score(X))
			guess = np.argmax(lhoods)
			gT = song/100 #Ground truth
			C[gT][guess] = C[gT][guess] + 1
		
		print "Finished fold %i: accuracy %g"%(fold, np.sum(np.diag(C))/np.sum(C))
	
	sio.savemat('GMMC.mat', {'C':C})
