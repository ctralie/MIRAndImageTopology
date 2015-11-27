#Programmer: Chris Tralie
#Purpose: To compute beat-synchronous self-similarity matrices on blocks of
#MFCC features for all of the second hand songs
import numpy as np
from sys import exit, argv
import scipy.misc
import spams

def getSSM(x, DPixels):
    D = np.reshape(np.sum(x**2, 1), [x.shape[0], 1])
    D = D + D.T - 2*x.dot(x.T)
    D[D < 0] = 0
    D = 0.5*(D + D.T)
    D = np.sqrt(D)
    return scipy.misc.imresize(D, [DPixels, DPixels])

if __name__ == '__main__':
    if len(argv) < 4:
        print "Usage: extractBeatSyncSSMs <BeatsPerBlock> <DPixels> <Num Dictionary Elements>"
        exit(0)
    BeatsPerBlock = int(argv[1])
    DPixels = int(argv[2])
    NDictElems = int(argv[3])
    fin = open("Features/bt_aligned_mfccs_shs.txt", "r")
    #Beat-synchronous self-similarity matrices file
    fout = open("Features/bt_aligned_ssm%imfccs_shs.txt"%BeatsPerBlock, "w")
    #Dictionary of self-similarity matrices file
    foutD = open("Features/bt_aligned_ssm%imfccs_dict%i_shs.txt"%(BeatsPerBlock, NDictElems), "w")
    NPixels = DPixels*(DPixels-1)/2 #Number of pixels in the upper right hand of each SSM
    fout.write("%i\n"%NPixels)
    #Select only upper right hand part of each SSM
    [I, J] = np.meshgrid(np.arange(DPixels), np.arange(DPixels))
    
    idx = 0
    line = fin.readline()
    while line:
        print "%i: %s"%(idx, line)
        fout.write(line)
        foutD.write(line)
        line = fin.readline()
        X = [float(a) for a in line.split(",")[0:-1]]
        X = np.reshape(X, [len(X)/12, 12])
        ND = X.shape[0] - BeatsPerBlock + 1
        if ND <= 0:
            fout.write("\n")
            foutD.write("\n")
            print "ND = 0"
            continue
        print "(NPixels, ND) = (%i, %i)"%(NPixels, ND)
        OutDs = np.zeros((NPixels, ND))
        for i in range(ND):
            x = X[i:i+BeatsPerBlock, :]
            D = getSSM(x, DPixels)
            OutDs[:, i] = D[I < J]
        Dict = spams.nnsc(np.asfortranarray(OutDs), lambda1 = 1, K = NDictElems)
        #Output colomn-major
        Dict = (Dict.T).flatten()
        OutDs = (OutDs.T).flatten()
        np.savetxt(fout, OutDs, fmt="%g", newline=",")
        fout.write("\n")
        np.savetxt(foutD, Dict, fmt="%g", newline=",")
        foutD.write("\n")
        line = fin.readline()
        idx += 1
    fin.close()
    fout.close()
    foutD.close()
