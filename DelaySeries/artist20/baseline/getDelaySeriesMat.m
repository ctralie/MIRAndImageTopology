%song: Relative path to song to use
%windowSize: Window size in seconds
%filename: The name of the output file
function [] = getDelaySeriesMat( song, windowSize, filename )
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
    
    SampleDelays = MFCCSAMPLELEN*(0:N-1);
    
    [soundSamples, Fs] = audioread(sprintf('../mp3s-32k/%s.mp3', song));
    
    save(filename, 'DelaySeries', 'SampleDelays', 'soundSamples', 'Fs');
end