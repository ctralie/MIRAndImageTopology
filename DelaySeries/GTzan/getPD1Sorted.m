%Programmer: Chris Tralie
%Purpose: To compute the persistence diagrams of the point cloud contained
%in X, where each row is a point and the columns are the dimensions
%Zero pads up to 100 persistence points
%Returns: XPD1Bars: [Birth Times, Life Times]
function [ XPD1Bars, JOrig ] = getPD1Sorted( X )
    javaclasspath('jars/tda.jar');
    import api.*;
    tda = Tda();
    D = squareform(pdist(X));
    maxEdgeLength = max(D(:));
    tda.RCA1( { 'settingsFile=data/cts.txt', 'supplyDataAs=distanceMatrix', ...
    	sprintf('distanceBoundOnEdges=%g', maxEdgeLength)}, D );
    disp('Finished Persistent Homology');
    J = tda.getResultsRCA1(1).getIntervals();
    JOrig = J;
    [~, idx] = sort(J(:, 2) - J(:, 2));
    J = J(idx, :);
    if size(J, 1) < 100
    	J = [J ; zeros(100 - size(J, 1), 2)];
    end
    J = J(1:100, :);
    XPD1Bars = [ J(:, 1)' (J(:, 2) - J(:, 1))' ];
end

