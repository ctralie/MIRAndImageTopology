function [I, J, JGenerators] = doHomology( filename,  hopSize, skipSize, windowSize )
    addpath('../TDAMex');
    [DelaySeries, Fs, SampleDelays] = getDelaySeriesFeatures( filename, hopSize, skipSize, windowSize );
    fprintf(1, 'Finished computing delay series with %i samples\n', length(SampleDelays));
    
    maxEdgeLength = 20;
    maxTime = 10;
    %Only look at the first 10 seconds
    SampleDelays = SampleDelays / Fs;
    lastIdx = sum(SampleDelays < maxTime)
    DelaySeries = DelaySeries(1:lastIdx, :);
    SampleDelays = SampleDelays(1:lastIdx, :);
    
    %Normalize data to the range [0, 1] in each dimension
    minData = min(DelaySeries);
    DelaySeries = bsxfun(@minus, DelaySeries, minData);
    maxData = max(DelaySeries);
    DelaySeries = bsxfun(@times, DelaySeries, 1./(maxData+eps));    
    %Calculate the distance matrix
    disp('Calculating distance matrix...');
    D = squareform(pdist(DelaySeries));
    minDist = min(D(:));
    maxDist = max(D(:));
    disp('Finished calculating distance matrix');
    disp('Beginning to get persistence points and generators...');
    [I, J, JGenerators] = getGeneratorsFromTDAJar(D, maxEdgeLength);
    disp('Finished getting persistence points and generators.');
    plotPersistenceDiagrams(I, J, minDist, maxDist);
    [~, genOrder] = sort(J(:, 2) - J(:, 1), 'descend');%Sort the points in
    %decreasing order of persistece
    %[~, genOrder] = sort(J(:, 1), 'ascend');%Sort the points in increasing order of birth time
    %[~, genOrder] = sort(J(:, 2), 'descend');%Sort the points in decreasing order of death time
    dimx = 5;
    figure;
    for i = 1:dimx*dimx
       subplot(dimx, dimx, i);
       plot(SampleDelays(JGenerators{genOrder(i)}));
       xlabel('Sample Number');
       ylabel('Seconds');
       title( sprintf('%g', J(genOrder(i), 2) - J(genOrder(i), 1)) );
    end
end