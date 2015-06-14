#Programmer: Chris Tralie
#Purpose: To demonstrate how a delay embedding plus circular cohomology (with
#the help of the Dionysus Library) can be used to get a finely sampled period
#of a multi sine signal from many low sampled periods
import numpy as np
import matplotlib.pyplot as plt
from pylab import cm
import subprocess #Used to call C++ compiled cohomology code from Dionysus
from cocycle import extractCocycle

def doPCA(X, ncomponents = 2):
	X = X - np.min(X, 0)
	X = X/np.max(X, 0)
	X = X - np.tile(np.mean(X, 0), (X.shape[0], 1))
	X[np.isinf(X)] = 0
	X[np.isnan(X)] = 0
	D = (X.T).dot(X)
	(lam, eigvecs) = np.linalg.eig(D)
	lam = np.abs(lam)
	varExplained = np.sum(lam[0:ncomponents])/np.sum(lam)
	print "%iD Var Explained: %g"%(ncomponents, np.sum(lam[0:2])/np.sum(lam))
	eigvecs = eigvecs[:, 0:ncomponents]
	Y = X.dot(eigvecs)
	return (Y, varExplained)

if __name__ == '__main__':
	#Step 1: Add a bunch of cosines together
	SamplesPerPeriod = 5
	NPeriods = 30
	t = np.linspace(0, 2*np.pi*NPeriods, SamplesPerPeriod*NPeriods)
	tfine = np.linspace(0, 2*np.pi, SamplesPerPeriod*NPeriods)
	#Magnitudes, frequencies, phases (mfp)
	mfp = [[1, 1, 0.5], [0.25, 1.5, 0.3]]#, [0.5, 2, 0]]
	NSines = len(mfp)
	#Print latex code for this equation
	print "\n\n"
	for i in range(NSines):
		vals = ['', '', '']
		for v in range(3):
			if not mfp[i][v] == 1:
				vals[v] = "%g"%mfp[i][v]
		print "%scos(2\\pi %st+%s)"%tuple(vals),
		if i < NSines-1:
			print "+",
	print "\n\n"
	mfp = np.array(mfp)
	y = np.zeros(len(t))
	yfine = np.zeros(len(t))
	for ii in range(NSines):
		y = y + mfp[ii, 0]*np.cos(mfp[ii, 1]*t + mfp[ii, 2])
		yfine = yfine + mfp[ii, 0]*np.cos(mfp[ii, 1]*tfine + mfp[ii, 2])
	
	#Step 2: Delay embedding (need 2*number of Fourier component dimensions)
	Y = np.zeros( (len(y) - 2*NSines + 1, 2*NSines) )
	for ii in range(NSines*2):
		Y[:, ii] = y[np.arange(ii, len(y)-NSines*2+ii+1)]

	#Step 3: Circular coordinates
	#First determine death value of most persistent class
	#init;
	#I = rca1pc(Y, 1e9);
	#cutoff = 0.99*max(I(:, 2));
	#TODO: Figure out threshold automatically
	cutoff = 0.8
	#http://www.mrzv.org/software/dionysus/examples/cohomology.html
	fout = open('points.txt', 'w')
	for i in range(Y.shape[0]):
		for j in range(Y.shape[1]):
			fout.write("%g "%Y[i, j])
		fout.write("\n")
	fout.close()
	subprocess.call(['./rips-pairwise-cohomology', 'points.txt', '-m', "%g"%cutoff, '-b', 'points.bdry', '-c', 'points', '-v', 'points.vrt', '-d', 'points.dgm'])
	theta = extractCocycle('points.bdry', 'points-0.ccl', 'points.vrt')
	circorder = np.argsort(theta)

	#Step 4: Make plots
	cmConvert = cm.get_cmap('jet')
	Colors = cmConvert(np.linspace(0, 1, len(y) ))[:, 0:3]
	plt.subplot(2, 2, 1)
	plt.plot(t, y)
	plt.hold(True)
	#plt.scatter(t, y, 20, Colors)
	plt.title('Original (%i sines %i samples per period)'%(NSines, SamplesPerPeriod))
	
	plt.subplot(2, 2, 2)
	Y, varExplained = doPCA(Y)
	plt.scatter(Y[:, 0], Y[:, 1], 20, Colors[0:Y.shape[0], :])
	plt.title('PCA Delay Embedding %.3g Percent Var Explained'%(100*varExplained))
	
	plt.subplot(2, 2, 3)
	plt.plot(y[circorder])
	plt.title('Resorted by Delay Coordinate Angles')
	
	plt.subplot(2, 2, 4)
	plt.plot(yfine)
	plt.title('Ground Truth Fine Period')
	
	plt.show()
	
	#Clean up temporary files
	subprocess.call(['rm', 'points.bdry'])
	subprocess.call(['rm', 'points.dgm'])
	subprocess.call(['rm', 'points.txt'])
	subprocess.call(['rm', 'points.vrt'])
	subprocess.call(['rm', 'points-0.ccl'])
