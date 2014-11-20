function [Is, Generators, AllSampleDelays, Ds] = localTDABeats( X, Fs, winSizeSec )
    addpath('../TDAMex');
    skipSizeSec = winSizeSec/50;
    TDAWinSizeSec = winSizeSec*4;
    
    disp('Computing Delay Series...');
    [DelaySeries, ~, SampleDelays] = getDelaySeriesFeatures( X, Fs, winSizeSec, skipSizeSec, 20 );
    disp('Finished Delay Series Computation');
    
    TDASkipSize = 10;
    TDAWindowSize = round(TDAWinSizeSec/skipSizeSec);
    TDAIntervals = 1:TDASkipSize:size(DelaySeries, 1)-TDAWindowSize;
    
    fprintf(1, 'Doing TDA in %i different intervals of size %i', length(TDAIntervals), TDAWindowSize);
    
    Is = cell(1, length(TDAIntervals));
    Generators = cell(1, length(TDAIntervals));
    AllSampleDelays = cell(1, length(TDAIntervals));
    Ds = cell(1, length(TDAIntervals));
    
    for ii = 1:length(TDAIntervals)
        idx = TDAIntervals(ii) + (1:TDAWindowSize);
        Y = DelaySeries(idx, :);
        Y = bsxfun(@minus, mean(Y), Y);
        Norm = 1./(sqrt(sum(Y.*Y, 2)));
        Y = Y.*(repmat(Norm, [1 size(Y, 2)]));        
        
%         [~, I, IGenerators] = getGeneratorsFromTDAJar(squareform(pdist(Y)));
%         Is{ii} = I;
%         Generators{ii} = IGenerators;
        
        AllSampleDelays{ii} = SampleDelays(idx);
        Ds{ii} = pdist(Y);
    end
end