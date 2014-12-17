%fs = {[0.5, 0.2, 0.3], [0.1, 0.4], [0.5, 0.2, 0.3]};
%TLs = [20, 30, 20, 30, 20];
fs = {[0.5, 0.2, 0.3], [0.1, 0.4]};
TLs = [20, 30, 20];
dt = 0.1;
T = 10;%Window length

%function [x, Y] = getTransientSpecEmbedding( fs, TLs, dt, T, doPhase )
[x, Y] = getTransientSpecEmbedding(fs, TLs, dt, T, 0);

C = colormap('jet');
N = length(x);
Colors = C( ceil( (1:N)*64/N ), :);

[~, YProj, latent] = pca(Y);

clf;
c = {'r', 'b', 'k', 'g', 'c', 'm', 'y'};
subplot(2, 2, 1);
scatter(dt*(0:length(x)-1), x, 10, Colors);
keyPoints = cumsum(TLs);
keyPoints = keyPoints(1:end-1);
hold on;
minVal = min(x(:));
maxVal = max(x(:));
for ii = 1:length(keyPoints)
    idx = mod((ii-1), length(c));
    idx = floor(idx/2) + 1;
    plot([keyPoints(ii), keyPoints(ii)], [minVal, maxVal], c{idx});
end
title('Time Series');


subplot(2, 2, 3);
scatter(YProj(:, 1), YProj(:, 2), 10, Colors(1:size(YProj, 1), :));
hold on;
for ii = 1:length(keyPoints)
    kk = round(keyPoints(ii)/dt);
    idx = mod((ii-1), length(c));
    idx = floor(idx/2) + 1;
    plot(YProj(kk, 1), YProj(kk, 2), sprintf('%sx', c{idx}));
end
title('PCA on Spectrum Embedding');
axis equal;

subplot(2, 2, 2);
imagesc(Y');
title('Spectrum Windows');

subplot(2, 2, 4);
plot(latent(1:min(15, length(latent))));
title('Eigenvalues');