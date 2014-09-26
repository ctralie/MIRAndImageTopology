load('points.mat')
X = bsxfun(@minus, mean(X), X);
X = bsxfun(@times, 1./std(X), X);
[~, XPCA] = pca(X);

ReducedNPoints = 1000;
D = squareform(pdist(X));
D = sort(D, 1);
[~, idx] = sort(mean(D(1:500, :)));

Y = X(idx(1:ReducedNPoints), :);
YPCA = XPCA(sort(idx(end:-1:end-ReducedNPoints)), :);
plot3(YPCA(:, 1), YPCA(:, 2), YPCA(:, 3), '.');