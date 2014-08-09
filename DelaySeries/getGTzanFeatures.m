function [] = getGTzanFeatures(indices)
    addpath('genres');
    genres = {'blues', 'classical', 'country', 'disco', 'hiphop', 'jazz', 'metal', 'pop', 'reggae', 'rock'};
    hopSize = 512;
    NWin = 43;
    featuresOrig = {};
    featuresTDA = {};

    %This is assuming a texture window (so means/variances)
    timbreIndices = [1:4 30:33 59];
    MFCCIndices = [5:9 34:38];
    ChromaIndices = [18:29 47:58];

    %Used for scaling before applying TDA
    featuresMin = [];
    featuresMax = [];

    for ii = 1:indices
       genre = genres{ii};
       fprintf(1, 'Doing %s...\n', genre);
       X = [];
       XTDA = [];
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
           thisXTDATimbre = getPD1Sorted(DelaySeries(:, timbreIndices));
           thisXTDAMFCC = getPD1Sorted(DelaySeries(:, MFCCIndices));
           thisXTDAChroma = getPD1Sorted(DelaySeries(:, ChromaIndices));
           if (isempty(XTDA))
              XTDA = zeros(100, length(thisXTDATimbre)*3); 
           end
           XTDA(jj, :) = [thisXTDATimbre thisXTDAMFCC thisXTDAChroma];
           fprintf(1, 'Finished %s %i\n', genre, jj);
       end
       featuresOrig{ii} = X;
       featuresTDA{ii} = XTDA;
       save(sprintf('GTzanFeatures%i.mat', ii), 'featuresOrig', 'featuresTDA', 'genres', 'featureNames');
    end
end