function [AllSampleDelays, Ds] = localMFCCBeats( X, Fs, bts, NMFCCs)
  	if nargin < 4
		NMFCCs = 20;
    end
    addpath('rastamat');
    BtsWin = 2;%Do sliding windows on 2 macrobeats
    SamplesPerWin = 200;
    
    N = length(bts) - BtsWin - 1;
    fprintf(1, 'Computing Delay Series on %i %i-macrobeat windows\n', N, BtsWin);
    
    AllSampleDelays = cell(1, N);
    Ds = cell(1, N);
    
    for ii = 1:N
        fprintf(1, 'Finished MFCCs %i of %i\n', ii, N);
        thisbts = bts(ii:ii + BtsWin);
        winSizeSec = mean(thisbts(2:end) - thisbts(1:end-1));
        winSize = round(Fs*winSizeSec);
        TDAWinSizeSec = BtsWin*winSizeSec;
        skipSizeSec = TDAWinSizeSec/SamplesPerWin;
        skipSize = round(Fs*skipSizeSec);
        startidx = round(Fs*thisbts(1));
        
        SampleDelays = zeros(1, SamplesPerWin);
        Y = zeros(SamplesPerWin, NMFCCs);
        for kk = 1:SamplesPerWin
            interval = startidx+skipSize*(kk-1) + (1:winSize);
            x = X(interval);
            Y(kk, :) = melfcc(x, Fs, 'maxfreq', 8000, 'numcep', NMFCCs, 'nbands', 40, 'fbtype', 'fcmel', 'dcttype', 1, 'usecmp', 1, 'wintime', winSizeSec, 'hoptime', winSizeSec, 'preemph', 0, 'dither', 1);
            SampleDelays(kk) = interval(1);
        end
        
        Y = bsxfun(@minus, mean(Y), Y);
        Norm = 1./(sqrt(sum(Y.*Y, 2)));
        Y = Y.*(repmat(Norm, [1 size(Y, 2)]));        
        
        AllSampleDelays{ii} = SampleDelays;
        Ds{ii} = pdist(Y);
    end
end