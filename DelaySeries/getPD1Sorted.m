function [ XPD1Bars ] = getPD1Sorted( X )
    javaclasspath('../TDAMex/jars/tda.jar');
    import api.*;
    tda = Tda();
    D = squareform(pdist(X));
    maxEdgeLength = max(D(:));
    tda.RCA1( { 'settingsFile=../TDAMex/data/cts.txt', 'supplyDataAs=distanceMatrix', ...
    	sprintf('distanceBoundOnEdges=%g', maxEdgeLength)}, D );
    disp('Finished Persistent Homology');
    J = tda.getResultsRCA1(1).getIntervals();
    [~, idx] = sort(J(:, 2) - J(:, 2));
    J = J(idx, :);
    if size(J, 1) < 100
    	J = [J ; zeros(100 - size(J, 1), 2)];
    end
    J = J(1:100, :);
    XPD1Bars = [ J(:, 1)' (J(:, 2) - J(:, 1))' ];
end

