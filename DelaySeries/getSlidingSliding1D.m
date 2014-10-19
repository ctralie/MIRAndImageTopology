%Programmer: Chris Tralie
%Purpose: To compute the 1D persistence diagrams in many small chunks 
%Returns an N-dim cell array Js, where N is the number of windows
function [ Js ] = getSlidingSliding1D( X, hopSize, windowSize, tda )
    D = squareform(pdist(X));
    maxEdgeLength = max(D(:));
    NX = size(X, 1);
    N = floor((NX - windowSize)/hopSize);
    Js = cell(1, N);
    M = 0;
    for ii = 1:N
        idx = 1 + (ii-1)*hopSize + (1:windowSize);
        tda.RCA1( { 'settingsFile=data/cts.txt', 'supplyDataAs=distanceMatrix', ...
            sprintf('distanceBoundOnEdges=%g', maxEdgeLength + 10)}, D(idx, idx) );
        Js{ii} = tda.getResultsRCA1(1).getIntervals();
        M = max(M, size(Js{ii}, 1));
    end
end