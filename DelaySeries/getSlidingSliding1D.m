%Programmer: Chris Tralie
%Purpose: To compute the 1D persistence diagrams in many small chunks 
%Returns an NxMx2 matrix J, where N is the number of windows and M is the 
%maximum number of persistence points for a window (and the last dimension
%is for birth/death)
function [ J ] = getSlidingSliding1D( X, hopSize, windowSize, tda )
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
    J = zeros(N, M, 2);
    for ii = 1:N
       J(ii, 1:size(Js{ii}, 1), :) = Js{ii}; 
    end
end