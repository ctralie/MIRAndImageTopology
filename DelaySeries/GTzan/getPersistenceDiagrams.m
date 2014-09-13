%Programmer: Chris Tralie
%Purpose: A wrapper function around John's RCA1 code
function [ J, I ] = getPersistenceDiagrams( X )
    javaclasspath('jars/tda.jar');
    import api.*;
    tda = Tda();
    D = squareform(pdist(X));
    maxEdgeLength = max(D(:));
    tda.RCA1( { 'settingsFile=data/cts.txt', 'supplyDataAs=distanceMatrix', ...
    	sprintf('distanceBoundOnEdges=%g', maxEdgeLength)}, D );
    disp('Finished Persistent Homology');
    J = tda.getResultsRCA1(1).getIntervals();
    I = tda.getResultsRCA1(0).getIntervals();
end