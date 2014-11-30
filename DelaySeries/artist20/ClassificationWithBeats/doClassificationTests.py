import numpy as np
from sklearn import mixture
from sys import argv, exit
import scipy.io as sio
import time
import pickle
import os

NCENTERSBEATS = 1
NCENTERSMFCCs = 3
NARTISTS = 20

if __name__ == '__main__':
	if len(argv) < 2:
		print "Usage doClassificationTests <folds file>"
		exit(0)
	
	artistsMap = {}
	artistNames = []
	artistModels = []
	artistModelsMFCC = []
	
	#Confusion matrix
	C = np.zeros((NARTISTS, NARTISTS))
	CBeats = np.zeros((NARTISTS, NARTISTS))
	CMFCCs = np.zeros((NARTISTS, NARTISTS))
	
	f = open(argv[1], 'r')
	fold = 0
	for line in f.readlines():
		#Go through each fold
		[trainList, testList] = line.split()
		fin = open(trainList, 'r')
		trainFiles = fin.readlines()
		fin.close()
		fin = open(testList, 'r')
		testFiles = fin.readlines()
		fin.close()
		
		#Read in features from training files
		print "Reading in %i training files for fold %i..."%(len(trainFiles), fold)
		for tf in trainFiles:
			artist = tf.split('/')[0]
			if not artist in artistsMap:
				artistsMap[artist] = len(artistsMap)
				artistModels.append(np.array([]))
				artistModelsMFCC.append(np.array([]))
				artistNames.append(artist)
			artistIdx = artistsMap[artist]
			
			filename = "../BeatsDict/" + tf.rstrip() + ".mat"
			varin = sio.loadmat(filename)
			alpha = varin['alpha'].toarray()
			
			filename = "../mfccs/" + tf.rstrip() + ".mat"
			varin = sio.loadmat(filename)
			MFCCs = varin['MFCCs']
			
			#print "Reading %s ...\n"%filename
			#print alpha.shape
			if len(artistModels[artistIdx]) == 0:
				artistModels[artistIdx] = alpha
				artistModelsMFCC[artistIdx] = MFCCs
			else:
				artistModels[artistIdx] = np.concatenate( (artistModels[artistIdx], alpha), 1)
				artistModelsMFCC[artistIdx] = np.concatenate( (artistModelsMFCC[artistIdx], MFCCs), 0)
		
		#Make GMMs for each artist
		for i in range(len(artistModels)):
			#TODO: Use something other than diagonal type for covariance matrices?
			
			#Fit beats GMM
			g = None
			filename = "%s%i_%i.pk"%(artistNames[i], fold, NCENTERSBEATS)
			if os.path.exists(filename):
				g = pickle.load( open(filename, "rb") )
				print "Loading precomputed beats GMM for " + artistNames[i]
			else:
				g = mixture.GMM(n_components = NCENTERSBEATS)
				print "Fitting beats GMM for " + artistNames[i] + "..."
				X = artistModels[i].T
				print X.shape
				tic = time.time()
				g.fit(X)
				toc = time.time() - tic
				print "Finished beats fitting GMM: Elapsed %g seconds"%toc
				#Cache artist model
				pickle.dump( g, open(filename, "wb") )
			artistModels[i] = g
			
			#Fit MFCCs GMM
			gMFCCs = None
			filename = "%s%i_%iMFCCs.pk"%(artistNames[i], fold, NCENTERSMFCCs)
			if os.path.exists(filename):
				g = pickle.load( open(filename, "rb") )
				print "Loading precomputed GMM for " + artistNames[i]
			else:
				g = mixture.GMM(n_components = NCENTERSBEATS)
				print "Fitting mfccs GMM for " + artistNames[i] + "..."
				print artistModelsMFCC[i].shape
				tic = time.time()
				g.fit(artistModelsMFCC[i])
				toc = time.time() - tic
				print "Finished mfccs fitting GMM: Elapsed %g seconds"%toc
				#Cache artist model
				pickle.dump( g, open(filename, "wb") )			
			artistModelsMFCC[i] = g
		
		#Now read in each test file and apply to GMM
		for tf in testFiles:
			filename = "../BeatsDict/" + tf.rstrip() + ".mat"
			print "Testing %s, "%filename,
			
			varin = sio.loadmat(filename)
			alpha = varin['alpha'].toarray()
			alpha = alpha.T
			
			filename = "../mfccs/" + tf.rstrip() + ".mat"
			varin = sio.loadmat(filename)
			MFCCs = varin['MFCCs']
					
			lhoodsbeats = np.zeros(NARTISTS)
			lhoodsmfccs = np.zeros(NARTISTS)
			lhoods = np.zeros(NARTISTS)
			#Try out the model from each artist
			for i in range(NARTISTS):
				##Average likelihood for each sample
				#(logprobs, lhoodspost) = artistModels[i].score_samples(alpha)
				#lhoodsmax = np.max(lhoodspost, 1) #Take max center probability
				#lhoods[i] = np.mean(lhoodsmax)
				lhoodsbeats[i] = np.mean(artistModels[i].score(alpha))
				lhoodsmfccs[i] = np.mean(artistModelsMFCC[i].score(MFCCs))
				lhoods[i] = lhoodsbeats[i] + lhoodsmfccs[i]
			guess = np.argmax(lhoods)
			guessBeats = np.argmax(lhoodsbeats)
			guessMFCCs = np.argmax(lhoodsmfccs)
			
			gT = artistsMap[tf.split('/')[0]] #Ground truth label
			C[gT][guess] = C[gT][guess] + 1.0
			CBeats[gT][guessBeats] = CBeats[gT][guessBeats] + 1.0
			CMFCCs[gT][guessMFCCs] = CMFCCs[gT][guessMFCCs] + 1.0
			
			print "label %s"%artistNames[guess]
		
		print "Finished fold %i\n"%fold
		print "Accuracy so far: %g"%(np.sum(np.diag(C))/np.sum(C))
		print "Beats Accuracy so far: %g"%(np.sum(np.diag(CBeats))/np.sum(CBeats))
		print "MFCCs Accuracy so far: %g"%(np.sum(np.diag(CMFCCs))/np.sum(CMFCCs))
		fold = fold + 1
		sio.savemat('C.mat', {'C':C, 'CBeats':CBeats, 'CMFCCs':CMFCCs})
	f.close()
	
	sio.savemat('C.mat', {'C':C, 'CBeats':CBeats, 'CMFCCs':CMFCCs})
