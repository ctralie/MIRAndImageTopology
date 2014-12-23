addpath('../../');

k = 10;
LandscapeRes = 50;
xrangeLandscape = linspace(0, 2, LandscapeRes);
yrangeLandscape = linspace(0, 0.6, LandscapeRes);

list1 = 'covers32k/list1.list';
files1 = textread(list1, '%s\n');

X = cell(length(files1), 1);
parfor ii = 1:length(files1)
    ii
    feats = load(sprintf('ftrsgeom/%s.mat', files1{ii}));
    Is = feats.Is;
    thisX = zeros(length(Is), LandscapeRes*LandscapeRes);
    for kk = 1:length(Is)
        L = getRasterizedLandscape(Is{kk}, xrangeLandscape, yrangeLandscape);
        thisX(kk, :) = L(:);
    end
    X{ii} = thisX;
end
X = cell2mat(X);
[~, C] = kmeans(X, k);

save(sprintf('KMeans%i.mat', k), 'C');