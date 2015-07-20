DEBUGFIEDLERMARCH = 1;
REPARAM = 0; %Whether or not to reparametrize by a random monotonic function (to study noise characteristics)

%Step 1: Add a bunch of cosines together
SamplesPerPeriod = 20;
NPeriods = 30;
NSamples = NPeriods*SamplesPerPeriod;
mfp = [1 1 0.5; 0.5 1.5 0.3];%; 0.8 2 0; 0.3 2 0.1];%; 0.6 1.3 0];
NSines = size(mfp, 1);

%Figure out the full period length (assuming I only go out to 1 decimal
%place with my frequencies)
Period = 2;
Period = Period*2*pi;

t = linspace(0, Period*NPeriods, NSamples);
if REPARAM
    %Come up with h(t), a monotonic time warping transformation
    ht = randn(1, length(t));
    ht = ht - min(ht);
    ht = cumsum(ht);
    ht = ht*Period*NPeriods/max(ht);
    ht = mean([ht; t; t; t; t], 1);
    NSamples = length(ht);
else
    ht = t;
end
tfine = linspace(0, Period, NSamples);

y = zeros(NSines, NSamples);
yfine = zeros(NSines, NSamples);
for ii = 1:NSines
    y(ii, :) = mfp(ii, 1)*sin(mfp(ii, 2)*ht + mfp(ii, 3));
    yfine(ii, :) = mfp(ii, 1)*sin(mfp(ii, 2)*tfine + mfp(ii, 3));
end
y = sum(y, 1)';
yfine = sum(yfine, 1)';

%Step 2: Delay embedding (need 2*number of Fourier component dimensions)
WindowLen = 2*NSines;
Y = zeros(length(y) - WindowLen + 1, WindowLen);
for ii = 1:WindowLen
    Y(:, ii) = y(ii:length(y)-WindowLen+ii);
end

[~, Z] = pca(Y);
plot3(Z(:, 1), Z(:, 2), Z(:, 3), '.');

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
title('Resorted After TSP');

subplot(2, 2, 3);
[~, Z, latent] = pca(Y);
Z = Z(:, 1:3);
C = colormap(sprintf('jet(%i)', size(Z, 1)));
scatter3(Z(path, 1), Z(path, 2), Z(path, 3), 20, C, 'fill');
axis equal;
title(sprintf('3D PCA (%.3g Percent Var)', 100*sum(latent(1:3))/sum(latent)));

%Amplify first two principal components of delay embedding and 
[U, S, V] = svd(Y);
figure(2);
clf;
plot(y(path));
colors = ['r', 'g', 'c', 'm', 'y'];
hold on;
for ii = 1:NSines
    ii
    d = zeros(1, size(Y, 1));
    d([1 2] + (ii-1)*2) = 1;
    SSub = diag(d)*S;
    YNew = U*SSub*V';
    ynew = NaN*ones(length(y), size(YNew, 2));
    for kk = 1:size(YNew, 2)
        ynew(kk:kk+size(YNew, 1)-1, kk) = YNew(:, kk);
    end
    ynew = nanmean(ynew, 2);
    plot(ynew(path), colors(ii));
end

t = t(:);
PCs = [cos(t(1:4)+0.5) sin(t(1:4)+0.5) cos(2*t(1:4)) sin(2*t(1:4))];