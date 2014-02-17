function [I, J, JGenerators] = doHomology( filename,  hopSize, skipSize, windowSize )
    addpath('../TDAMex');
    [DelaySeries, Fs, SampleDelays] = getDelaySeriesFeatures( filename, hopSize, skipSize, windowSize );
    fprintf(1, 'Finished computing delay series with %i samples\n', length(SampleDelays));
    %Normalize data to the range [0, 1] in each dimension
%     songFrac = 6;
    songFrac = 1;
    DelaySeries = DelaySeries(1:size(DelaySeries,1)/songFrac, :);
    SampleDelays = SampleDelays(1:size(SampleDelays/songFrac, 1), :);
    N = size(DelaySeries, 1);
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
    [I, J, JGenerators] = getGeneratorsFromTDAJar(D);
    disp('Finished getting persistence points and generators.');
    plotPersistenceDiagrams(I, J, minDist, maxDist);
    [~, genRange] = sort(J(:, 2) - J(:, 1), 'descend');
    dimx = 5;
    figure;
    for i = 1:dimx*dimx
       subplot(dimx, dimx, i);
       plot(SampleDelays(JGenerators{genRange(i)})/Fs);
       xlabel('Sample Number');
       ylabel('Seconds');
       title( sprintf('%g', J(genRange(i), 2) - J(genRange(i), 1)) );
    end
end