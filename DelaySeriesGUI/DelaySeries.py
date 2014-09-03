import numpy as np
import numpy.linalg as linalg
from scipy.io import wavfile
from scipy.io import savemat
from scipy.fftpack import dct
import matplotlib.pyplot as plt

#MFCC CONSTANTS
MEL_NBANDS = 40
MEL_MINFREQ = 0
MEL_MAXFREQ = 8000
#CHROMA CONSTANTS
A440 = 440.0
A0 = A440/16.0
NCHROMABINS = 12
NCHROMABINS2 = np.round(NCHROMABINS/2)
FCTR = 1000 #hz
OCTAVEWIDTH = 1

#Mirror what Matlab's code does
def STFTNoOverlapZeropad(X, hopSize):
	N = X.shape[0]
	ham = np.hamming(hopSize) #Use hamming window
	#Zeropad X so that there are an integer number of hopSize intervals
	N2 = hopSize*np.ceil(N/float(hopSize))
	Y = np.zeros(N2)
	Y[0:N] = X
	S = np.array([ np.fft.fft(ham*Y[i:i+hopSize]) for i in range(0, len(Y) - hopSize, hopSize) ])
	return S.T

#Chroma does windows that are 4x as long as the hop size
#(this gives more frequency resolution at the expense of time resolution)
def STFTChromaOverlap(X, hopSize):
	N = X.shape[0]
	windowLen = hopSize*4
	ham = np.hamming(windowLen)
	N2 = windowLen*np.ceil(N/float(windowLen))
	Y = np.zeros(N2)
	Y[0:N] = X
	S = np.array([ np.fft.fft(ham*Y[i:i+windowLen]) for i in range(0, len(Y) - windowLen, hopSize)  ])
	return S.T

def getRMSE(x):
	return np.sqrt(np.sum(np.abs(x*x))/float(len(x)))

#function [DelaySeries, Fs, SampleDelays, FeatureNames] = getDelaySeriesFeatures( filename, hopSize, skipSize, windowSize )
class DelaySeries(object):
	def __init__(self):
		self.DelaySeries = []
		self.filename = ""
		self.hopSize = 512
		self.skipSize = 1
		self.windowSize = 43
	
	def processFile(self, filename, hopSize = 512, skipSize = 1, windowSize = 43):
		self.filename = filename
		self.hopSize = hopSize
		self.skipSize = skipSize
		self.windowSize = windowSize

		Fs, X = wavfile.read(filename)
		#X = pcm2float(X, np.float32) 
		if len(X.shape) > 1 and X.shape[1] > 1:
			#Merge to mono if there is more than one channel
			X = X.sum(1)
		X = X.flatten()
		#Data is not normalized when read in.  Assume 16 bit
		X = X/(2.0**15)

		#Compute spectrogram
		S = STFTNoOverlapZeropad(X, hopSize) #Spectrogram
		S = np.abs(S)
		SHalf = S[0:hopSize/2+1, :] #Non-redundant spectrogram
		P = np.abs(S)**2 #Periodogram
		NSpectrumSamples = SHalf.shape[0]
		NAWindows = S.shape[1]

		######################################################
		#####            TIMBRAL FEATURES           ##########
		######################################################
		#Spectral Centroid
		MulMat = np.tile(1 + np.arange(NSpectrumSamples), (NAWindows, 1))
		MulMat = MulMat.T
		Centroid = np.sum(SHalf*MulMat, 0)/np.sum(SHalf, 0)
		Centroid = Centroid.reshape((1, len(Centroid)))
		
		#Spectral Roloff
		EPS = 1e-14
		Roloff = np.cumsum(SHalf, 0) / np.tile(np.sum(SHalf, 0) + EPS, (NSpectrumSamples, 1))
		Roloff[Roloff > 0.85] = 1.0
		Roloff[Roloff <= 0.85] = 0
		Roloff = NSpectrumSamples - np.sum(Roloff, 0)
		Roloff = Roloff.reshape((1, len(Roloff)))

		#Spectral Flux
		S2Half = SHalf.copy()
		S2Half[:, 1:] = S2Half[:, 0:-1]
		S2Half[:, 0] = 0
		Flux = SHalf - S2Half
		Flux = np.sum(Flux*Flux, 0)
		Flux = Flux.reshape((1, len(Flux)))

		#Zero Crossings
		XDelay = X.copy()
		XDelay[1:] = X[0:-1]
		XDelay[0] = 0
		AllZeroCrossings = 0.5*np.abs(np.sign(X) - np.sign(XDelay))
		ZeroCrossings = np.zeros(NAWindows)
		for i in range(NAWindows):
			i1 = i*hopSize
			i2 = min((i+1)*hopSize, hopSize*NAWindows-1)
			ZeroCrossings[i] = np.sum(AllZeroCrossings[i1:i2])
		ZeroCrossings = ZeroCrossings.reshape((1, len(ZeroCrossings)))

		######################################################
		#####  MEL-FREQUENCY CEPSTRAL COEFFICIENTS  ##########
		######################################################
		#TODO: Apply loudness correction in "postaud.m" of rastamat?
		#TODO: Apply dither to spectrum?
		#MFCC = melfcc(X, Fs, 'maxfreq', 8000, 'numcep', 13, 'nbands', 40, 'fbtype', 'fcmel', 'dcttype', 1, 'usecmp', 1, 'wintime', winSizeSec, 'hoptime', winSizeSec, 'preemph', 0, 'dither', 1);
		#Step 1: Warp to the mel-frequency scale
		melbounds = np.array([MEL_MINFREQ, MEL_MAXFREQ])
   		melbounds = 1125*np.log(1 + melbounds/700.0)
   		mel = np.linspace(melbounds[0], melbounds[1], MEL_NBANDS)
   		binfreqs = 700*(np.exp(mel/1125.0) - 1)
   		binbins = np.floor(((hopSize-1)/float(Fs))*binfreqs) #Floor to the nearest bin
   		
   		#Step 2: Create mel triangular filterbank
   		melfbank = np.zeros((MEL_NBANDS, hopSize))
   		for i in range(MEL_NBANDS):
   			thisbin = binbins[i]
   			lbin = thisbin
   			if i > 0:
   				lbin = binbins[i-1]
   			rbin = thisbin + (thisbin - lbin)
   			if i < MEL_NBANDS - 1:
   				rbin = binbins[i+1]
   			melfbank[i, lbin:thisbin+1] = np.linspace(0, 1, 1 + (thisbin - lbin))
   			melfbank[i, thisbin:rbin+1] = np.linspace(1, 0, 1 + (rbin - thisbin))
   		
   		#Step 3: Apply mel filterbank to periodogram, and compute log of the result
   		preMFCC = np.array( [melfbank.dot(P[:, i].T) for i in range(NAWindows)] ).T
   		preMFCC = np.log(preMFCC)
   		
   		#Step 4: Compute DCT and return components 1:6 (the first five non-DC components)
   		MFCC = dct(preMFCC, axis = 0, norm = 'ortho')
   		MFCC = MFCC[1:6, :]
   		
		######################################################
		#####             CHROMA FEATURES           ##########
		######################################################
		#Mainly translating code from Dan Ellis's "chromagram_P" and "fft2chromamx"	
		SChroma = np.abs(STFTChromaOverlap(X, hopSize))
		chr_hopSize = hopSize*4
		SChroma = SChroma[0:chr_hopSize/2+1, :]
		#Convert frequency index to midi note number (plus possible fixed offset)
		fftfreqbins = NCHROMABINS*np.log( (np.arange(1, chr_hopSize)*float(Fs)/chr_hopSize)/A0 )/np.log(2)
		fftfreqbins = np.append(fftfreqbins[0]-1.5*chr_hopSize, fftfreqbins)
		nwidthbins = np.append(fftfreqbins[1:] - fftfreqbins[0:-1], 1)
		nwidthbins = nwidthbins.reshape(1, len(nwidthbins))
		temp = np.ones(nwidthbins.shape)
		binwidthbins = np.max( np.concatenate((nwidthbins, temp), 0), 0)
		D = np.tile(fftfreqbins.reshape(1, len(fftfreqbins)), (NCHROMABINS, 1))
		D = D - np.tile(np.reshape(np.arange(NCHROMABINS), (NCHROMABINS, 1)), (1, chr_hopSize))
		D = np.mod(D + NCHROMABINS2 + 10*NCHROMABINS, NCHROMABINS) - NCHROMABINS2
		#Create a weight matrix based both on a center frequency and a width
		f_ctr_log = np.log(FCTR/A0)/np.log(2)
		wts = np.exp(-0.5*( 2*D/(np.tile(binwidthbins, (NCHROMABINS, 1))**2) ))
		#Normalize each column
		wts = wts/np.tile(np.sum(wts, 0)**2, (NCHROMABINS, 1))
		#Apply scaling
		wts = wts*np.tile(np.exp(-0.5*( ((fftfreqbins/NCHROMABINS - f_ctr_log)/OCTAVEWIDTH)**2)), (NCHROMABINS, 1) )
		#Apply chroma transformation matrix to half-spectrogram
		#for the final result
		#Keep only local maxes
		idxbefore = np.append(0, np.arange(0, SChroma.shape[0]-1))
		idxafter = np.append(np.arange(1, SChroma.shape[0]), SChroma.shape[0]-1)
		SChroma = SChroma*(SChroma >= SChroma[idxbefore, :])*(SChroma >= SChroma[idxafter, :])
		wts = wts[:, 0:chr_hopSize/2+1]
		Chroma = wts.dot(SChroma)
		#Zeropad chroma so it has the same number of samples as everything else
		zeropadFac = MFCC.shape[1] - Chroma.shape[1]
		print "Zeropadding chroma by %i"%zeropadFac
		if zeropadFac >= 0:
			Chroma = np.concatenate((Chroma, np.zeros((Chroma.shape[0], zeropadFac))), 1)
		else:
			Chroma = Chroma[:, 0:MFCC.shape[1]]
		
		######################################################
		#####        DELAY SERIES COMPUTATION       ##########
		######################################################		
		#The last 1 is for low energy feature
		TimbreIdx = np.arange(Centroid.shape[0] + Roloff.shape[0] + Flux.shape[0] + ZeroCrossings.shape[0])
		MFCCIdx = np.arange(len(TimbreIdx), len(TimbreIdx) + MFCC.shape[0])
		ChromaIdx = np.arange(len(TimbreIdx) + len(MFCCIdx), len(TimbreIdx) + len(MFCCIdx) + Chroma.shape[0])
		NFeatures = len(TimbreIdx) + len(MFCCIdx) + len(ChromaIdx)
		if windowSize > 1:
			#Include mean/standard deviation and the low energy feature
			TimbreIdx = np.append(TimbreIdx, TimbreIdx + NFeatures)
			TimbreIdx = np.append(TimbreIdx, NFeatures*2) #low energy features
			MFCCIdx = np.append(MFCCIdx, MFCCIdx + NFeatures)
			ChromaIdx = np.append(ChromaIdx, ChromaIdx + NFeatures)
			NFeatures = NFeatures*2 + 1
		
		#Compute the RMSE of each analysis window in the time domain
		AnalysisWinRMSE = np.array([getRMSE(X[i*hopSize:(i+1)*hopSize]) for i in range(NAWindows)])
		
		#Compute the mean and variance over each texture window
		NDelays = len(range(0, len(X)-hopSize*windowSize-1, hopSize*skipSize))
		DelaySeries = np.zeros((NDelays, NFeatures))
		SampleDelays = np.zeros(NDelays)
		for off in range(NDelays):
			i1 = off*skipSize
			i2 = i1 + windowSize
			SampleDelays[off] = i1*hopSize
			#Compute mean and standard deviation over the window of: Centroid, Roloff,
			#Flux, ZeroCrossings, MFCC
			StackedFeatures = np.concatenate((Centroid[:, i1:i2], Roloff[:, i1:i2], Flux[:, i1:i2], ZeroCrossings[:, i1:i2], MFCC[:, i1:i2], Chroma[:, i1:i2]), 0)
			if windowSize == 1:
				DelaySeries[off, :] = StackedFeatures.flatten()
			else:
				MeanStacked = np.mean(StackedFeatures, 1)
				STDStacked = np.sqrt(np.var(StackedFeatures, 1))
				#Compute the very last feature, which is the low-energy feature
				TextureWinRMSE = getRMSE(X[hopSize*i1:hopSize*i2])
				ZeroEnergy = np.array([sum(AnalysisWinRMSE[i1:i2] < TextureWinRMSE)])
				DelaySeries[off, :] = np.concatenate((MeanStacked, STDStacked, ZeroEnergy))
		SampleDelays = SampleDelays/Fs
		return X, DelaySeries, Fs, SampleDelays, TimbreIdx, MFCCIdx, ChromaIdx

	def processFilePCA(self, filename, hopSize = 512, skipSize = 1, windowSize = 43, ncomponents = 2):
		Samples, DelaySeries, Fs, SampleDelays, TimbreIdx, MFCCIdx, ChromaIdx = self.processFile(filename, hopSize, skipSize, windowSize)
		DelaySeries = DelaySeries - np.min(DelaySeries, 0)
		DelaySeries = DelaySeries/np.max(DelaySeries, 0)
#		pca = PCA(ncomponents)
#		pca.fit(DelaySeries)
#		Y = pca.transform(DelaySeries)
		X = DelaySeries - np.tile(np.mean(DelaySeries, 0), (DelaySeries.shape[0], 1))
		X[np.isinf(X)] = 0
		X[np.isnan(X)] = 0
		D = (X.T).dot(X)
		(lam, eigvecs) = linalg.eig(D)
		eigvecs = eigvecs[:, 0:ncomponents]
		Y = X.dot(eigvecs)
		return Samples, Y, Fs, SampleDelays

#if __name__ == '__main__':
##	Fs, X = wavfile.read('reggae0.wav')
##	S = STFTNoOverlapZeropad(X, 512)
##	plt.imshow(np.abs(S))
##	plt.show()
#	s = DelaySeries()
#	Samples, Y, SampleDelays = s.processFilePCA('hiphop0.wav', 512, 1, 43)
#	#Y, SampleDelays = s.processFilePCA('piano-chrom.wav', 512, 1, 23)
#	fig = plt.figure()
#	ax = p3.Axes3D(fig)
#	ax.scatter3D(Y[:, 0], Y[:, 1], SampleDelays)
#	plt.show()
