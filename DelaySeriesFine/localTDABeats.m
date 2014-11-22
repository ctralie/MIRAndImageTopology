function [DelaySeries, SampleDelays, AllSampleDelays, Ds] = localTDABeats( X, Fs, winSizeSec, DelaySeriesIn, SampleDelaysIn )
    addpath('../TDAMex');
    
    TDASkipSize = 50;
    skipSizeSec = winSizeSec/TDASkipSize;
    TDAWinSizeSec = winSizeSec*4;%Use 4 microbeats
    
    if nargin < 5
        disp('Computing Delay Series...');
        [DelaySeries, ~, SampleDelays] = getDelaySeriesFeatures( X, Fs, winSizeSec, skipSizeSec, 20 );
        disp('Finished Delay Series Computation');
    else
        DelaySeries = DelaySeriesIn;
        SampleDelays = SampleDelaysIn;
    end
    
    
    TDAWindowSize = round(TDAWinSizeSec/skipSizeSec);
    TDAIntervals = 1:TDASkipSize:size(DelaySeries, 1)-TDAWindowSize;
    
    fprintf(1, 'Doing TDA in %i different intervals of size %i', length(TDAIntervals), TDAWindowSize);
    
    AllSampleDelays = cell(1, length(TDAIntervals));
    Ds = cell(1, length(TDAIntervals));
    
    for ii = 1:length(TDAIntervals)
        idx = TDAIntervals(ii) + (1:TDAWindowSize);
        Y = DelaySeries(idx, :);
        Y = bsxfun(@minus, mean(Y), Y);
        Norm = 1./(sqrt(sum(Y.*Y, 2)));
        Y = Y.*(repmat(Norm, [1 size(Y, 2)]));        
        
        AllSampleDelays{ii} = SampleDelays(idx);
        Ds{ii} = pdist(Y);
    end
end