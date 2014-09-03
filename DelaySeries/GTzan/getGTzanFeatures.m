%Programmer: Chris Tralie
%Purpose: To extract the CAF and persistence features from the George
%Tzanetakis 2002 dataset
%indices: The indices of the genres to compute (Useful to run this file
%on different cores with different indices to parallelize computation)
function [] = getGTzanFeatures(indices, subsample, foldername)
    addpath('genres');
    addpath('..');
    addpath('../chroma-ansyn');
    addpath('../rastamat');
    genres = {'blues', 'classical', 'country', 'disco', 'hiphop', 'jazz', 'metal', 'pop', 'reggae', 'rock'};
    hopSize = 512;
    NWin = 43;
    featuresOrig = {};
    featuresTDA = {};
    AllPDs1 = {};
    AllPDS0 = {};
    if nargin < 2
        subsample = 1;
    end
    if nargin < 3
        foldername = '.'; 
    end
    %This is assuming a texture window (so means/variances)
    timbreIndices = [1:4 30:33 59];
    MFCCIndices = [5:9 34:38];
    ChromaIndices = [18:29 47:58];

    %Used for scaling before applying TDA (scale by the range of the first
    %song)
    featuresMin = [];
    featuresMax = [];

    for ii = 1:length(indices)
       genre = genres{indices(ii)};
       fprintf(1, 'Doing %s...\n', genre);
       X = [];
       XTDA = [];
       PDs1 = {};
       PDs0 = {};
       for jj = 1:100
           filename = sprintf('genres/%s/%s.%.5i.au', genre, genre, jj-1);
           [DelaySeries, ~, ~, FeatureNames] = getDelaySeriesFeatures(filename, hopSize, 1, NWin);
           %Save the mean and variance of all features to "featuresOrig"
           thisX = [mean(DelaySeries, 1) var(DelaySeries, 1)];
           if isempty(X)
              X = zeros(jj, length(thisX)); 
           end
           X(jj, :) = thisX;
           %Now scale the delay series and compute the DGM1 features
           if isempty(featuresMin)
               featuresMin = min(DelaySeries, [], 1);
               featuresMax = max(DelaySeries, [], 1);
           end
           DelaySeries = bsxfun(@minus, DelaySeries, featuresMin);
           DelaySeries = bsxfun(@times, DelaySeries, 1./((featuresMax - featuresMin)+eps));
           %Do DGM1 separately for timbre, MFCC, and chroma
           %Subsample the point clouds by a factor of 2
           [thisXTDATimbre, timbrePD1, timbrePD0] = getPD1Sorted(DelaySeries(1:subsample:end, timbreIndices));
           [thisXTDAMFCC, MFCCPD1, MFCCPD0] = getPD1Sorted(DelaySeries(1:subsample:end, MFCCIndices));
           [thisXTDAChroma, ChromaPD1, ChromaPD0] = getPD1Sorted(DelaySeries(1:subsample:end, ChromaIndices));
           if (isempty(XTDA))
              XTDA = zeros(100, length(thisXTDATimbre)*3); 
           end
           XTDA(jj, :) = [thisXTDATimbre thisXTDAMFCC thisXTDAChroma];
           fprintf(1, 'Finished %s %i\n', genre, jj);
           PDs1{end+1} = {timbrePD1, MFCCPD1, ChromaPD1};
           PDs0{end+1} = {timbrePD0, MFCCPD0, ChromaPD0};
       end
       featuresOrig{ii} = X;
       featuresTDA{ii} = XTDA;
       AllPDs1{ii} = PDs1;
       AllPDs0{ii} = PDs0;
       save(sprintf('%s/GTzanFeatures%i.mat', foldername, indices(ii)), 'X', 'XTDA', 'PDs1', 'PDs0', 'genres', 'FeatureNames');
    end
end
