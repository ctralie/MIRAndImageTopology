%song: Relative path to song to use
%windowSize: Window size in seconds
%fileprefix: The prefix of the output files which will store the sound
%and the delay series
function [] = getDelaySeriesJavascriptPCA( song, windowSize, outprefix )
    MFCCSAMPLELEN = 0.016;

    %Compute MFCC Delay Series
    MFCC = readhtk(sprintf('../mfccs/%s.htk', song));
    MFCCWindowSize = round(windowSize/MFCCSAMPLELEN);%Each MFCC window is 15 milliseconds
    p = (size(MFCC, 2))*2;
    N = size(MFCC, 1) - MFCCWindowSize;
    DelaySeries = zeros(N, p);
    for ii = 1:N
        idx = ii:ii+MFCCWindowSize-1;
        MFCCFeats = [mean(MFCC(idx, :)) std(MFCC(idx, :))];
        DelaySeries(ii, :) = MFCCFeats;
    end
    DelaySeries = bsxfun(@minus, mean(DelaySeries), DelaySeries);
    DelaySeries = bsxfun(@times, 1./std(DelaySeries), DelaySeries);
    [~, DelaySeries] = pca(DelaySeries);    
    
    SampleDelays = MFCCSAMPLELEN*(0:N-1);
    
    [soundSamples, Fs] = audioread(sprintf('../mp3s-32k/%s.mp3', song));
    
    audiowrite(sprintf('%s.ogg', outprefix), soundSamples, Fs);
    
    fout = fopen(sprintf('%s.txt', outprefix), 'w');
    for ii = 1:size(DelaySeries, 1)
       fprintf(fout, '%g,%g,%g,%g,', DelaySeries(ii, 1), DelaySeries(ii, 2), DelaySeries(ii, 3), SampleDelays(ii)); 
    end
    fclose(fout);
end