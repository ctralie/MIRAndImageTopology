%Programmer: Chris Tralie
%Purpose: A wrapper function around John's RCA1 code
%Returns: I: 0D persistence diagram, J: 1D Persistence Diagram
%JBK: Birth and Death edges for 1D persistence diagram
function [ I, J, JBK ] = getPersistenceDiagrams( X, tda )
    D = squareform(pdist(X));
    N = size(D, 1);
    maxEdgeLength = max(D(:));
    tda.RCA1( { 'settingsFile=data/cts.txt', 'supplyDataAs=distanceMatrix', ...
    	sprintf('distanceBoundOnEdges=%g', maxEdgeLength + 10)}, D );
    disp('Finished Persistent Homology');
    J = tda.getResultsRCA1(1).getIntervals();
    I = tda.getResultsRCA1(0).getIntervals();
    %Determine the birthing and killing edge for the 1D persistence diagram
    JBK = zeros(size(J, 1), 4);
    [ColIdx, RowIdx] = meshgrid(1:N, 1:N);
    for ii = 1:size(J, 1)
        birthEdge = find(D == J(ii, 1), 1);
        JBK(ii, 1) = RowIdx(birthEdge);
        JBK(ii, 2) = ColIdx(birthEdge);
        deathEdge = find(D == J(ii, 2), 1);
        JBK(ii, 3) = RowIdx(deathEdge);
        JBK(ii, 4) = ColIdx(deathEdge);
    end
end