%song: Relative path to song to use
%filename: The name of the output file
%doRAW: Compute raw embedding?
function [] = getDelaySeriesMat( song, hopSize, skipSize, windowSize, filePrefix, doRAW )
    if nargin < 6
       doRaw = 0; 
    end
    [soundSamples, Fs] = audioread(song);
    if size(soundSamples, 2) > 1
        soundSamples = mean(soundSamples, 2);%Put down to one channel if necessary
    end
    [DelaySeries, ~, SampleDelays] = getDelaySeriesFeatures(song, hopSize, skipSize, windowSize);
    
    SampleDelays = SampleDelays/Fs;
    
    save(sprintf('%sCAF.mat', filePrefix), 'DelaySeries', 'SampleDelays', 'soundSamples', 'Fs');

    if doRaw == 1
        DelaySeries = getDelaySeriesRaw(song, hopSize, skipSize, windowSize);
        fprintf(1, 'There are %i samples\n', size(DelaySeries, 1));
        DelaySeries = bsxfun(@minus, mean(DelaySeries), DelaySeries);

        disp('Doing dimension reduction...');
        D = squareform(pdist(DelaySeries));
        fprintf(1, 'size(D) = (%i, %i)\n', size(D, 1), size(D, 2));
        DelaySeries = cmdscale(D);
        DelaySeries = DelaySeries(:, 1:3);
        disp('Finished dimension reduction');

        save(sprintf('%sRaw.mat', filePrefix), 'DelaySeries', 'SampleDelays', 'soundSamples', 'Fs');
    end
end