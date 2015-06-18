DEBUGFIEDLERMARCH = 1;

%Step 1: Add a bunch of cosines together
SamplesPerPeriod = 5;
NPeriods = 100;
K = 2;
NSamples = NPeriods*SamplesPerPeriod;
t = linspace(0, 2*pi*NPeriods, NSamples);
tfine = linspace(0, 20*pi, NSamples);

mfp = [1 1 0.5; 0.5 1.5 0.3; 0.25 2 0; 0.3 2 0.1; 0.6 1.3 0];
NSines = size(mfp, 1);

y = zeros(NSines, NSamples);
yfine = zeros(NSines, NSamples);
for ii = 1:NSines
    y(ii, :) = mfp(ii, 1)*sin(mfp(ii, 2)*t + mfp(ii, 3));
    yfine(ii, :) = mfp(ii, 1)*sin(mfp(ii, 2)*tfine + mfp(ii, 3));
end
y = sum(y, 1)';
yfine = sum(yfine, 1)';

%Step 2: Delay embedding (need 2*number of Fourier component dimensions)
Y = zeros(length(y) - 2*NSines + 1, 2*NSines);
for ii = 1:2*NSines
    Y(:, ii) = y(ii:length(y)-NSines*2+ii);
end

% %Step 3: Fiedler March
% [fiedler, path, A] = fiedlerMarch( Y, K, 0 );
path = doTSP(squareform(pdist(Y)), 1);

%Step 4: Plot
figure(1);
clf;
subplot(2, 2, 1);
plot(y);
title(sprintf('Original Signal (%i Sines)', NSines));
subplot(2, 2, 2);
plot(yfine);
title('Ground Truth Fine');

subplot(2, 2, 4);
plot(y(path));
title(sprintf('Resorted After Fiedler TSP', K));

subplot(2, 2, 3);
[~, Z, latent] = pca(Y);
Z = Z(:, 1:3);
C = colormap(sprintf('jet(%i)', size(Z, 1)));
scatter3(Z(path, 1), Z(path, 2), Z(path, 3), 20, C, 'fill');
title(sprintf('3D PCA (%.3g Percent Var)', 100*sum(latent(1:3))/sum(latent)));
