%INPUTS
%hopSize: hopSize to use with the STFT (the number of samples in each STFT
%window, referred to as the "analysis window")
%skipSize (integer): The program will use a number of samples equal to 
%hopSize*skipSize in between delay series samples
%windowSize (integer): The number of hopSizes to use for each delay series sample
%(this is also referred to as the "texture window")
%NOTE: A windowSize of 1 skips using a texture window

%RETURNS
%DelaySeries: The delay series point cloud, with the points along the rows
%and the features along the columns
%Fs: Sampling Frequency
%SampleDelays: Where each delay sample starts (sample number in the sound
%file)
%FeatureNames: A cell array of strings that describe each feature
function [DelaySeries, Fs, SampleDelays, FeatureNames] = getDelaySeriesFeatures( filename, hopSize, skipSize, windowSize )
    addpath('chroma-ansyn');
    addpath('rastamat');
    readSuccess = 0;
    %Prevents the mandlebug where matlab's audio read randomly fails
    while readSuccess == 0
        try
            [X, Fs] = audioread(filename);
            readSuccess = 1;
        catch
            readSuccess = 0;
        end
    end
    if nargin == 1
    	%Default Parameters
    	hopSize = round(2048*Fs/44100.0);
    	skipSize = 1;
    	windowSize = 1;%By default do not use a texture window
    end    
    if size(X, 2) > 1
       %Merge to mono if there is more than one channel
       X = sum(X, 2)/size(X, 2); 
    end
    
    %Compute timbral features based on spectrogram
    disp('Calculating spectrogram timbral features....');
    S = spectrogram(X, hopSize, 0);
    S = abs(S);
    NSpectrumSamples = size(S, 1);
    NAWindows = size(S, 2);
    
    %Spectral Centroid
    MulMat = repmat((1:NSpectrumSamples)', [1, NAWindows]);
    Centroid = sum(S.*MulMat)/NSpectrumSamples;
    
    %Spectral Roloff
    Roloff = cumsum(S, 1)./repmat(sum(S, 1) + eps, NSpectrumSamples, 1);
    Roloff(Roloff > 0.85) = 100;
    Roloff(Roloff <= 0.85) = 0;
    Roloff = sum(Roloff) / 100.0;
    
    %Spectral Flux
    S2 = [zeros(NSpectrumSamples, 1) S(:, 1:end-1)];
    Flux = S - S2;
    Flux = sum(Flux.*Flux);
   
    %Zero crossings
    XDelay = [0; X(1:end-1)];
    AllZeroCrossings = 0.5*abs(sign(X) - sign(XDelay));
    ZeroCrossings = zeros(1, NAWindows);
    for ii = 1:length(ZeroCrossings)
       ZeroCrossings(ii) =  sum(AllZeroCrossings(1+(ii-1)*hopSize:ii*hopSize));
    end
    
    %Use Dan Ellis's MFCC code
    disp('Calculating MFCC features....');
    winSizeSec = hopSize/Fs;
    MFCC = melfcc(X, Fs, 'maxfreq', 8000, 'numcep', 13, 'nbands', 40, 'fbtype', 'fcmel', 'dcttype', 1, 'usecmp', 1, 'wintime', winSizeSec, 'hoptime', winSizeSec, 'preemph', 0, 'dither', 1);

    %Use Dan Ellis's Chroma code
    disp('Calculating chroma features....');
    Chroma = chromagram_IF(X, Fs, hopSize*4);
    %For some reason the chroma features are one index off
    Chroma = [Chroma zeros(size(Chroma, 1), 1)];    
    
    %Now compute delay series
    disp('Calculating delay series....');
    %The last 1 is for low energy feature
    NFeatures = 2*(size(Centroid, 1) + size(Roloff, 1) + size(Flux, 1) + size(ZeroCrossings, 1) + size(MFCC, 1) + size(Chroma, 1)) + 1;
    if windowSize == 1
       %Exclude the mean/standard deviation and the low energy feature if
       %the window size is 1
       NFeatures = (NFeatures - 1)/2; 
    end
    
    %Save the string name of the features
    FeatureNames = {};
    FeatureNames{1} = 'Centroid'; FeatureNames{2} = 'Roloff'; FeatureNames{3} = 'Flux';
    FeatureNames{4} = 'ZeroCrossings';
    offset = length(FeatureNames);
    for ii = 1:size(MFCC, 1)
       FeatureNames{offset + ii} = sprintf('MFCC%i', ii); 
    end
    Notes = {'A', 'A#', 'B', 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#'};
    offset = length(FeatureNames);
    for ii = 1:length(Notes)
        FeatureNames{offset + ii} = sprintf('Chroma_%s', Notes{ii});
    end
    if windowSize > 1
        %Do the mean/variance and zero-energy feature if using a texture
        %window
        offset = length(FeatureNames);
        for ii = 1:offset
           OrigName = FeatureNames{ii};
           FeatureNames{ii} = sprintf('MEAN%i_%s', windowSize, OrigName);
           FeatureNames{offset + ii} = sprintf('STD%i_%s', windowSize, OrigName);
        end
        FeatureNames{length(FeatureNames)+1} = 'ZeroEnergy';
    end
    FeatureNames = FeatureNames';
    
    %Compute the mean and variance over each texture window 
    NDelays = length(1:hopSize*skipSize:length(X)-hopSize*windowSize-1);
    DelaySeries = zeros(NDelays, NFeatures);
    SampleDelays = zeros(NDelays, 1);
    for off = 1:NDelays
        i1 = 1 + (off-1)*skipSize;
        i2 = i1 + windowSize - 1;
        SampleDelays(off) = i1*hopSize;
        %Compute mean and standard deviation over the window of: Centroid, Roloff, Flux, ZeroCrossings, Chroma, MFCC
        StackedFeatures = [Centroid(:, i1:i2); Roloff(:, i1:i2); Flux(:, i1:i2); ZeroCrossings(:, i1:i2); MFCC(:, i1:i2); Chroma(:, i1:i2)];
        if windowSize == 1
            DelaySeries(off, :) = StackedFeatures;
        else
            MeanStacked = mean(StackedFeatures, 2);
            STDStacked = sqrt(var(StackedFeatures, 1, 2));
            %Compute the very last feature, which is the low-energy feature
            SSubset = S(:, i1:i2);
            SSubsetEnergy = sum(SSubset.*SSubset, 1);
            ZeroEnergy = sum(SSubsetEnergy < mean(SSubsetEnergy));
            DelaySeries(off, :) = [MeanStacked; STDStacked; ZeroEnergy];
        end
        if mod(off, 100) == 0
           fprintf(1, 'Finished %i of %i\n', off, NDelays); 
        end
    end
    DelaySeries = DelaySeries(:, 1:NFeatures);
end