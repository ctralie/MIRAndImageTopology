function [] = doHomologyOld(data)
    javaclasspath('jars/tda.jar');
    import api.*;
    tda = Tda();

    doSparseMatrix = 0;
    doMDS = 1;

    %Normalize data to the range [0, 1] in each dimension
    N = size(data, 1);
    minData = min(data);
    data = bsxfun(@minus, data, minData);
    maxData = max(data);
    data = bsxfun(@times, data, 1./(maxData+eps));
    %data = [data linspace(0, 2, size(data, 1))'];%Add a dimension which is the number of the delay sample
    %Calculate the euclidean pairwise distance row vector
    disp('Calculating distance matrix....');
    D = pdist(data, 'euclidean');
    disp('Finished calculating distance matrix');

    if doMDS == 1
        disp('Doing multidimensional scaling....');
        %Do multidimensional scaling
        [Y,eigvals] = cmdscale(D);
        disp('Finished multidimensional scaling');
        %scatter3(Y(:, 1), Y(:, 2), Y(:, 3), 10, 1:size(data, 1));
        scatter(Y(:, 1), Y(:, 2), 10, 1:size(data, 1));
    end

    disp('Getting max dist');
    %maxDist = quantile(D, 0.05) %Only include the top 5% of distances
    maxDist = 0.8;
    minDist = 0;
    disp('Finished getting max dist');
    DSparse = [0 0 0];
    if doSparseMatrix == 1
        %Make a sparse distance matrix
        minDist = min(D);
        index = 1;
        DCount = 1;
        %Store upper triangular part in sparse matrix
        disp('Creating sparse distance matrix');
        for i = 1:N
           for j = i+1:N
               if D(DCount) < maxDist
                  DSparse(index, :) = [i j D(DCount)];
                  index = index + 1;
               end
               DCount = DCount + 1;
           end
        end
        disp('Finished creating sparse distance matrix');
    end
    clear D;

    disp('Starting Persistent Homology');
    if doSparseMatrix == 1
        tda.RCA1( { 'settingsFile=data/cts.txt', 'supplyDataAs=sparseMatrix',sprintf('distanceBoundOnEdges=%g', maxDist)}, DSparse );
    else
        %tda.RCA1( { 'settingsFile=data/cts.txt', 'supplyDataAs=distanceMatrix',sprintf('distanceBoundOnEdges=%g', maxDist)}, squareform(D) );
        tda.RCA1( { 'settingsFile=data/cts.txt', 'supplyDataAs=pointCloud', sprintf('distanceBoundOnEdges=%g', maxDist)}, data );
    end
    disp('Finished Persistent Homology');
    I = tda.getResultsRCA1(0).getIntervals();
    J = tda.getResultsRCA1(1).getIntervals();
    figure;
    plot(I(:, 1), I(:, 2), '.');
    xlim([minDist, maxDist]);
    ylim([minDist, maxDist]);
    axis square;
    title('0D Persistence Diagram');

    figure;
    plot(J(:, 1), J(:, 2), '.');
    xlim([minDist, maxDist]);
    ylim([minDist, maxDist]);
    hold on;
    plot([minDist, maxDist], [minDist, maxDist], 'r');
    axis square;
    title('1D Persistence Diagram');

end
