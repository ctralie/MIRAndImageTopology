function [mins, maxs, vars] = getScalingInfo(indices)
    addpath('genres');
    addpath('..');
    addpath('../chroma-ansyn');
    addpath('../rastamat');
    genres = {'blues', 'classical', 'country', 'disco', 'hiphop', 'jazz', 'metal', 'pop', 'reggae', 'rock'};
    hopSize = 512;
    NWin = 43;

    X = [];
    for ii = 1:length(indices)
       genre = genres{indices(ii)};
       fprintf(1, 'Doing %s...\n', genre);
       for jj = 1:100
           filename = sprintf('genres/%s/%s.%.5i.au', genre, genre, jj-1);
           [DelaySeries, ~, ~, FeatureNames] = getDelaySeriesFeatures(filename, hopSize, 1, NWin);
           X = [X;DelaySeries];
       end
    end
    mins = min(X, [], 1);
    maxs = max(X, [], 1);
    vars = var(X, 1);
end