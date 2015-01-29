function [AllSampleDelays, Ds, PointClouds, C, Chroma] = localChromaBeats( X, Fs, bts, BtsWin)
    if nargin < 4
    	BtsWin = 2;%Do sliding windows on 2 macrobeats by default
    end
    AvgFactor = 10;
    
    addpath('chroma-ansyn');
    N = length(bts) - BtsWin - 1;
    fprintf(1, 'Computing Chroma Delay Series on %i %i-macrobeat windows\n', N, BtsWin);
    
    windowSize = round(Fs/(20*4))*4 %Make the window size about 50 milliseconds
    macroHopSize = windowSize/4
    
    %Get as close as possible to 200 samples per window
    windowSamples = Fs*mean(bts(2:end) - bts(1:end-1))*BtsWin; 
    hopSize = macroHopSize/floor(macroHopSize/(windowSamples/200))
    NHops = macroHopSize/hopSize;%Number of offsets at which to compute chroma
    
    %Calculate chroma at all of the offsets and interleave them all
    %together
    C = cell(1, NHops);
    for ii = 1:length(C)
        fprintf(1, 'Calculating chromas %i of %i\n', ii, length(C));
        offset = 1+(ii-1)*hopSize;
        C{ii} = chromagram_IF(X(offset:end), Fs, windowSize);
    end
    CSizes = cellfun(@(x) size(x, 2), C);
    Chroma = zeros(size(C{1}, 1), sum(CSizes));
    for ii = 1:length(C)
        Chroma(:, ii:length(C):end) = C{ii};
    end
    %Now perform averaging by the average factor
    NextChroma = zeros(size(Chroma, 1), size(Chroma, 2) - AvgFactor + 1);
    for ii = 1:size(NextChroma, 2)
        NextChroma(:, ii) = mean(Chroma(:, ii:ii+AvgFactor-1), 2);
    end
    Chroma = NextChroma;
    SampleDelays = 1:size(Chroma, 2);
    SampleDelays = (SampleDelays-1)*hopSize/Fs;
    
    
    AllSampleDelays = cell(1, N);
    Ds = cell(1, N);
    PointClouds = cell(1, N);
    for ii = 1:N
        i1 = find(SampleDelays >= bts(ii), 1);
        i2 = find(SampleDelays > bts(ii+BtsWin), 1);
        PointClouds{ii} = Chroma(:, i1:i2)';
        AllSampleDelays{ii} = SampleDelays(i1:i2);
%         PointClouds{ii} = Y;
%         Y = bsxfun(@minus, mean(Y), Y);
%         Norm = 1./(sqrt(sum(Y.*Y, 2)));
%         Y = Y.*(repmat(Norm, [1 size(Y, 2)]));
%         
%         %AllSampleDelays{ii} = SampleDelays;
%         Ds{ii} = pdist(Y);
    end
end
