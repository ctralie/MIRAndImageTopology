addpath('genres');
genres = {'blues', 'classical', 'country', 'disco', 'hiphop', 'jazz', 'metal', 'pop', 'reggae', 'rock'};
hopSize = 512;
NWin = 43;
featuresOrig = {};
featuresTDA = {};

%Used for scaling before applying TDA
featuresMin = [];
featuresMax = [];

for ii = 1:length(genres)
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
       thisXTDA = getPD1Sorted(DelaySeries);
       if (isempty(XTDA))
          XTDA = zeros(100, length(thisXTDA)); 
       end
       XTDA(jj, :) = thisXTDA;
       fprintf(1, 'Finished %s %i\n', genre, jj);
   end
   featuresOrig{ii} = X;
   featuresTDA{ii} = XTDA;
   save('GTzanFeatures.mat', 'featuresOrig', 'featuresTDA', 'genres', 'featureNames');
end