%Step 1: Add a bunch of cosines together
SamplesPerPeriod = 5;
NPeriods = 30;
NSamples = NPeriods*SamplesPerPeriod;
t = linspace(0, 2*pi*NPeriods, NSamples);
tfine = linspace(0, 4*pi, NSamples);

mfp = [1 1 0.5];%; 0.5 1.5 0.3; 0.25 2 0];
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

%Step 3: Build mutual nearest neighbor graph and make laplacian
K = 2;
DMetric = squareform(pdist(Y));
[NNF, NNFD, A] = getKNN(DMetric, K);
D = sum(A, 2);
L = spdiags(D, 0, speye(size(A, 1)))-A;

[E, V] = eigs(L, 2, 'sm');
fiedler = E(:, end-1); %Fiedler vector
theta = atan2(Y(:, 2), Y(:, 1));


%Step 4: Use fiedler vector to traverse the graph
visited = zeros(1, length(fiedler));
path = ones(1, length(fiedler));
path(1) = 1;
visited(1) = 1;
for ii = 2:length(fiedler)
    neighbs = NNF(path(ii-1), :);
    neighbs = neighbs(visited(neighbs) == 0);
    if isempty(neighbs)
        fprintf(1, 'Stopped at %i\n', ii);
        break;
    end
    dists = abs(fiedler(neighbs) - fiedler(ii-1));
    [~, minidx] = min(dists);
    path(ii) = neighbs(minidx);
    visited(neighbs(minidx)) = 1;
end


%Step 5: Plot
clf;
subplot(2, 2, 1);
plot(y);
title('Original Signal');
subplot(2, 2, 2);
plot(yfine);
title('Ground Truth Fine');

subplot(2, 2, 4);
plot(y(path));
title('Resorted After Fiedler March');

subplot(2, 2, 3);
[~, Z] = pca(Y);
Z = Z(:, 1:2);
Z = [Z fiedler(:)];
C = colormap(sprintf('jet(%i)', size(Z, 1)));
scatter3(Z(path, 1), Z(path, 2), Z(path, 3), 20, 'fill');
hold on;
for ii = 1:size(NNF, 1)
    for jj = 1:size(NNF, 2)
        P = [Z(ii, :); Z(NNF(ii, jj), :)];
        plot3(P(:, 1), P(:, 2), P(:, 3), 'r');
    end
end
title('3D PCA On Delay Embedding');
