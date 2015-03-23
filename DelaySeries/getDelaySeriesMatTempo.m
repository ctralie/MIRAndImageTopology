%song: Relative path to song to use
%filename: The name of the output file
%doRAW: Compute raw embedding?
function [DelaySeriesTempo, SampleDelaysTempo, DelaySeriesTempoStacked, SampleDelaysTempoStacked] = 
    getDelaySeriesMatTempo( soundfilename, tempoPeriod, filePrefix )
    [X, Fs] = audioread(soundfilename);
    if size(X, 2) > 1
        X = mean(X, 2);
    end
    [DelaySeries, SampleDelays] = getMFCCTempoWindow(soundfilename, tempoPeriod);
    SampleDelaysTempo = SampleDelays;
    DelaySeriesTempo = DelaySeries;
    save(sprintf('%sTempo.mat', filePrefix), 'DelaySeries', 'SampleDelays', 'Fs', 'soundfilename');
    
    %Now get stacked MFCCs
    windowSize = 1024.0;
    hopSize = 512.0;
    NMFCCs = 20;
    %TODO: Make hop size smaller than window size
    MFCCs = melfcc(X, Fs, 'maxfreq', 8000, 'numcep', NMFCCs, 'nbands', 40, 'fbtype', ...
            'fcmel', 'dcttype', 1, 'usecmp', 1, 'wintime', windowSize/Fs, 'hoptime', hopSize/Fs, 'preemph', 0, 'dither', 1)';
    NStacked = round(tempoPeriod/(windowSize/Fs)) %How many windows to stack
    dim = NMFCCs*NStacked;
    N = size(MFCCs, 1) - NStacked + 1;
    DelaySeries = zeros(N, dim);
    for ii = 1:N
        thisWin = MFCCs(ii:ii+NStacked-1, :);
        DelaySeries(ii, :) = thisWin(:);
    end
    DelaySeriesTempoStacked = DelaySeries;
    SampleDelays = (0:N-1)*hopSize/Fs;
    SampleDelaysTempoStacked = SampleDelays;
    save(sprintf('%sTempoStacked.mat', filePrefix), 'DelaySeries', 'SampleDelays', 'Fs', 'soundfilename');
end