function [I1, J1, J1Generators, cycleDists] = getGeneratorsFromTDAJar(D, varargin)
    javaclasspath('../TDAMex/jars/tda.jar');
    import api.*;
    tda = Tda();
    
    maxEdgeLength = [];
    if nargin > 1
        maxEdgeLength = varargin{1};
    end

    fprintf(1, 'Executing my code...\n');
    tic;
    if isempty(maxEdgeLength)
        [~, J2, J1Generators, cycleDists] = Persistence0D1D(D);
    else
        [~, J2, J1Generators, cycleDists] = Persistence0D1D(D, maxEdgeLength);
    end
    toc;
    
    fprintf(1, 'Executing John''s code...\n');
    if isempty(maxEdgeLength)
        tda.RCA1( { 'settingsFile=../TDAMex/data/cts.txt', 'supplyDataAs=distanceMatrix'}, D );
    else
        tda.RCA1( { 'settingsFile=../TDAMex/data/cts.txt', 'supplyDataAs=distanceMatrix', ...
            sprintf('distanceBoundOnEdges=%g', maxEdgeLength)}, D );
    end
    disp('Finished Persistent Homology');
    I1 = tda.getResultsRCA1(0).getIntervals();
    J1 = tda.getResultsRCA1(1).getIntervals();

    newGenerators = cell(1, size(J1, 1));
    newCycleDists = zeros(1, size(J1, 1));
    for k = 1:size(J1, 1)
       birthTime = J1(k, 1);
       indices = find( J2(:, 1) == repmat(birthTime, [size(J2, 1), 1]), size(J2, 1) );
       if length(indices) == 0
           disp('Error: Cycle not found by my code which was found by Prof Harers code');
       elseif length(indices) > 1
           disp('Warning: More than one cycle found at the same birth time in my code');
       end
       if length(indices) == 1
          newGenerators{k} = J1Generators{indices(1)};
          newCycleDists(k) = cycleDists(k);
       end
    end
    J1Generators = newGenerators;
    cycleDists = newCycleDists;
end
