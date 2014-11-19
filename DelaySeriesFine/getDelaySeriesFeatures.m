%windowSize and skipSize are specified in seconds now
function [DelaySeries, Fs, SampleDelays] = getDelaySeriesFeatures( X, Fs, winSizeSec, skipSizeSec, NMFCCs )
	if nargin < 4
		NMFCCs = 20;
    end
    addpath('rastamat');
    
    windowSize = round(winSizeSec*Fs);
    skipSize = round(skipSizeSec*Fs);
    N = floor((length(X) - windowSize)/skipSize)
    
    DelaySeries = zeros(N, NMFCCs);
    parfor ii = 1:N
        x = X(skipSize*(ii-1) + (1:windowSize));
        MFCC = melfcc(x, Fs, 'maxfreq', 8000, 'numcep', NMFCCs, 'nbands', 40, 'fbtype', 'fcmel', 'dcttype', 1, 'usecmp', 1, 'wintime', winSizeSec, 'hoptime', winSizeSec, 'preemph', 0, 'dither', 1);
        DelaySeries(ii, :) = MFCC;
        SampleDelays(ii) = skipSize*(ii-1) + 1;
    end
end