%song: Relative path to song to use
%filename: The name of the output file
function [] = getDelaySeriesMat( song, hopSize, skipSize, windowSize, filePrefix )    
    [soundSamples, Fs] = audioread(song);
    [DelaySeries, ~, SampleDelays] = getDelaySeriesFeatures(song, hopSize, skipSize, windowSize);
    
    SampleDelays = SampleDelays/Fs;
    
    save(sprintf('%sCAF.mat', filePrefix), 'DelaySeries', 'SampleDelays', 'soundSamples', 'Fs');
    DelaySeries = getDelaySeriesRaw(song, hopSize, skipSize, windowSize);
    fprintf(1, 'There are %i samples\n', size(DelaySeries, 1));
    DelaySeries = bsxfun(@minus, mean(DelaySeries), DelaySeries);
%     disp('Doing 3D PCA....');
%     D = DelaySeries'*DelaySeries;
%     [U, ~] = eigs(D, 3);
%     DelaySeries = DelaySeries*U;
%     disp('Finished PCA');
    disp('Doing dimension reduction...');
    D = squareform(pdist(DelaySeries));
    fprintf(1, 'size(D) = (%i, %i)\n', size(D, 1), size(D, 2));
    DelaySeries = cmdscale(D);
    DelaySeries = DelaySeries(:, 1:3);
    disp('Finished dimension reduction');

    save(sprintf('%sRaw.mat', filePrefix), 'DelaySeries', 'SampleDelays', 'soundSamples', 'Fs');
end