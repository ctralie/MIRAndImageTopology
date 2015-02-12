init;
% t = linspace(0, 2*pi, 100);
% X = [cos(t(:)) sin(t(:))];
% X = [X; 2+0.5*cos(t(:)) 2+0.5*sin(t(:))];
% Y = X+0.03*randn(size(X));
% I1 = rca1pc(X, 1e9);
% I2 = rca1pc(Y, 1e9);
% idx = randperm(size(I2, 1));
% I2 = I2(idx, :);

% load('TestDists.mat');
% D2 = fliplr(flipud(D2));
% D1 = imresize(imresize(D1, [20, 20]), size(D1));
% D2 = imresize(imresize(D2, [20, 20]), size(D2));
% 
% tic
% [I11, Generators11] = morseFiltration2DMex(D1);
% [I12, Generators12] = morseFiltration2DMex(max(D1(:))-D1);
% [I21, Generators21] = morseFiltration2DMex(D2);
% [I22, Generators22] = morseFiltration2DMex(max(D2(:))-D2);
% 
I1 = I11;
I2 = I21;
% I1 = I1((I1(:, 1) < 0.4) & (I1(:, 1) > 0.15), :);
% I2 = I2((I2(:, 1) < 0.4) & (I2(:, 1) > 0.15), :);
% I1 = [0.01347 0.4857];
% I2 = [0.02996 0.6181];
[matchidx, matchdist, D] = getWassersteinDist(I1, I2);

clf;
% subplot(1, 2, 1);
% plot(X(:, 1), X(:, 2), 'b.');
% hold on;
% plot(Y(:, 1), Y(:, 2), 'r.');
% 
% subplot(1, 2, 2);
plotWassersteinMatching(I1, I2, matchidx);
title(sprintf('Wasserstein Dist: %g', matchdist));