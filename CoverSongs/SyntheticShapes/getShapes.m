addpath('../../TDAMex');
N = 200;
t = linspace(0, 2*pi, N);
X = [5*cos(t)' sin(t)', ones(length(t), 1)];
D = squareform(pdist(X));

subplot(1, 2, 1);
plot3(X(:, 1), X(:, 2), X(:, 3));
axis equal;

subplot(1, 2, 2);
imagesc(D)
[I, Gens] = morseFiltration2DMex(D);
hold on;
Gens = cellfun( @(x) x(end), Gens);
[GensX, GensY] = ind2sub(size(D), Gens);
plot(GensX, GensY, 'rx');