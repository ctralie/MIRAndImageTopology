%song: Relative path to song to use
%windowSize: Window size in seconds
%fileprefix: The prefix of the output files which will store the sound
%and the delay series
%sphereNormalize: Normalize to the N-dimensional sphere?
%indices: Which indices to take
function [] = getDelaySeriesJavascriptPCA( song, windowSize, outprefix, sphereNormalize, indices )
    MFCCSAMPLELEN = 0.016;

    %Compute MFCC Delay Series
    MFCC = readhtk(sprintf('../mfccs/%s.htk', song));
    MFCCWindowSize = round(windowSize/MFCCSAMPLELEN);%Each MFCC window is 16 milliseconds
    p = (size(MFCC, 2))*2;
    N = size(MFCC, 1) - MFCCWindowSize;
    DelaySeries = zeros(N, p);
    for ii = 1:N
        idx = ii:ii+MFCCWindowSize-1;
        MFCCFeats = [mean(MFCC(idx, :)) std(MFCC(idx, :))];
        DelaySeries(ii, :) = MFCCFeats;
    end
    if nargin < 4
        sphereNormalize = 0;
    end
    if nargin < 5
        indices = 1:size(DelaySeries, 1);
    end
    DelaySeries = DelaySeries(indices, :);
    DelaySeries = bsxfun(@minus, mean(DelaySeries), DelaySeries);
    
    if sphereNormalize
        %Do what's done in the Sw1pers paper
        Norm = 1./(sqrt(sum(DelaySeries.*DelaySeries, 2)));
        DelaySeries = DelaySeries.*(repmat(Norm, [1 size(DelaySeries, 2)]));
    else
        DelaySeries = bsxfun(@times, 1./std(DelaySeries), DelaySeries);
    end
    
    [~, DelaySeries, latent] = pca(DelaySeries);
    
    SampleDelays = MFCCSAMPLELEN*(0:N-1);
    
    [soundSamples, Fs] = audioread(sprintf('../mp3s-32k/%s.mp3', song));
    
    audiowrite(sprintf('%s.ogg', outprefix), soundSamples, Fs);
    
    fout = fopen(sprintf('%s.txt', outprefix), 'w');
    for ii = 1:size(DelaySeries, 1)
       fprintf(fout, '%g,%g,%g,%g,', DelaySeries(ii, 1), DelaySeries(ii, 2), DelaySeries(ii, 3), SampleDelays(ii)); 
    end
    fprintf(fout, '%g', sum(latent(1:3))/sum(latent));%Variance explained
    fclose(fout);
end