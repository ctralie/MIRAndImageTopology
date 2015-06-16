DEBUGFIEDLERMARCH = 1;

%Step 1: Add a bunch of cosines together
SamplesPerPeriod = 5;
NPeriods = 30;
NSamples = NPeriods*SamplesPerPeriod;
t = linspace(0, 2*pi*NPeriods, NSamples);
tfine = linspace(0, 4*pi, NSamples);

mfp = [1 1 0.5; 0.5 1.5 0.3; 0.25 2 0];
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
K = 3;
DMetric = squareform(pdist(Y));
[NNF, NNFD, A] = getKNN(DMetric, K);
%A = A.*DMetric;
D = sum(A, 2);
L = spdiags(D, 0, speye(size(A, 1)))-A;

[E, V] = eigs(L, 2, 'sm');
fiedler = E(:, end-1); %Fiedler vector


%Step 4: Use fiedler vector to traverse the graph
visited = zeros(1, length(fiedler));
path = ones(1, length(fiedler));
path(1) = 1;
visited(1) = 1;
if DEBUGFIEDLERMARCH
    [~, Z] = pca(Y);
    Z = Z(:, 1:3);
    C = colormap(sprintf('jet(%i)', size(Z, 1)));
    scatter3(Z(path, 1), Z(path, 2), Z(path, 3), 20, C, 'fill');
    [~, fidx] = sort(fiedler);
end
for ii = 2:length(fiedler)
    if DEBUGFIEDLERMARCH
        clf;
        scatter(Z(fidx, 1), Z(fidx, 2), 20, C, 'fill');
        hold on;
        scatter(Z(path(1:ii-1), 1), Z(path(1:ii-1), 2), 60, 'k', 'x');
        scatter(Z(path(ii-1), 1), Z(path(ii-1), 2), 80, 'k', 'fill');
        %Plot neighbor lines
        for jj = find(A(path(ii-1), :))
            P = [Z(path(ii-1), :); Z(jj, :)];
            plot(P(:, 1), P(:, 2), 'r', 'LineWidth', 2);
            scatter(Z(jj, 1), Z(jj, 2), 70, 'k', 'o');
        end
        %Plot path lines
        for kk = 1:ii-2
            for jj = find(A(path(kk), :))
                P = [Z(path(kk), :); Z(jj, :)];
                plot(P(:, 1), P(:, 2), 'b');
            end
        end
%Uncomment to zoom
%         z = Z(path(ii-1), :);
%         xlim([min(z(:, 1)) - 0.4, max(z(:, 1)) + 0.4]);
%         ylim([min(z(:, 2)) - 0.4, max(z(:, 2)) + 0.4]);
    end
    
    neighbs = find(A(path(ii-1), :));
    neighbs = neighbs(visited(neighbs) == 0);
    if isempty(neighbs)
        fprintf(1, 'Stopped at %i\n', ii);
        break;
    end
    dists = abs(fiedler(neighbs) - fiedler(ii-1));
    [~, minidx] = min(dists);
    path(ii) = neighbs(minidx);
    visited(neighbs(minidx)) = 1;
    
    if DEBUGFIEDLERMARCH
        scatter(Z(path(ii), 1), Z(path(ii), 2), 70, 'b', 'fill');
        print('-dpng', '-r100', sprintf('%i.png', ii));
    end
end


%Step 5: Plot
clf;
subplot(2, 2, 1);
plot(y);
title(sprintf('Original Signal (%i Sines)', NSines));
subplot(2, 2, 2);
plot(yfine);
title('Ground Truth Fine');

subplot(2, 2, 4);
plot(y(path));
title(sprintf('Resorted After Fiedler March (%i NN)', K));

subplot(2, 2, 3);
[~, Z, latent] = pca(Y);
Z = Z(:, 1:3);
C = colormap(sprintf('jet(%i)', size(Z, 1)));
scatter3(Z(path, 1), Z(path, 2), Z(path, 3), 20, C, 'fill');
hold on;
for ii = 1:size(Z, 1)
    for jj = find(A(ii, :))
        P = [Z(ii, :); Z(jj, :)];
        plot3(P(:, 1), P(:, 2), P(:, 3), 'r');
    end
end
title(sprintf('3D PCA (%.3g Percent Var)', 100*sum(latent(1:3))/sum(latent)));
