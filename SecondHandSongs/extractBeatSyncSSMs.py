import numpy as np
from sys import exit, argv
import spams

def getSSM(x):
    D = np.reshape(np.sum(x**2, 1), [x.shape[0], 1])
    D = D + D.T - 2*x.dot(x.T)
    D[D < 0] = 0
    D = 0.5*(D + D.T)
    return np.sqrt(D)

if __name__ == '__main__':
    if len(argv) < 3:
        print "Usage: extractBeatSyncSSMs <BeatsPerBlock> <Num Dictionary Elements>"
        exit(0)
    BeatsPerBlock = int(argv[1])
    NDictElems = int(argv[2])
    fin = open("Features/bt_aligned_mfccs_shs.txt", "r")
    #Beat-synchronous self-similarity matrices file
    fout = open("Features/bt_aligned_ssm%imfccs_shs.txt"%BeatsPerBlock, "w")
    #Dictionary of self-similarity matrices file
    foutD = open("Features/bt_aligned_ssm%imfccs_dict%i_shs.txt"%(BeatsPerBlock, NDictElems), "w")
    NPixels = BeatsPerBlock*(BeatsPerBlock-1)/2 #Number of pixels in the upper right hand of each SSM
    fout.write("%i\n"%NPixels)
    #Select only upper right hand part of each SSM
    [I, J] = np.meshgrid(np.arange(BeatsPerBlock), np.arange(BeatsPerBlock))
    
    line = fin.readline()
    while line:
        print line
        fout.write(line)
        foutD.write(line)
        line = fin.readline()
        X = [float(a) for a in line.split(",")[0:-1]]
        X = np.reshape(X, [len(X)/12, 12])
        ND = X.shape[0] - BeatsPerBlock + 1
        OutDs = np.zeros((NPixels, ND))
        for i in range(ND):
            x = X[i:i+BeatsPerBlock, :]
            D = getSSM(x)
            OutDs[:, i] = D[I < J]
        Dict = spams.nnsc(np.asfortranarray(OutDs), lambda1 = 1, K = NDictElems)
        #Output colomn-major
        Dict = (Dict.T).flatten()
        OutDs = (OutDs.T).flatten()
        np.savetxt(fout, Dict, fmt="%g", newline=",")
        fout.write("\n")
        np.savetxt(foutD, OutDs, fmt="%g", newline=",")
        foutD.write("\n")
        line = fin.readline()
    fin.close()
    fout.close()
    foutD.close()
