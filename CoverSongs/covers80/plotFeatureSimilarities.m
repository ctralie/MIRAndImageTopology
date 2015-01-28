function [DRips, DEucGeo, DGH, DL2Stress] = plotFeatureSimilarities( s1prefix, s2prefix, outname )

    feats1 = load(sprintf('ftrsgeom/%s.mat', s1prefix));
    feats2 = load(sprintf('ftrsgeom/%s.mat', s2prefix));

    %DGM1 landscapes
    xrangeLandscape = linspace(0, 2, 50);
    yrangeLandscape = linspace(0, 0.6, 50);    
    N = length(xrangeLandscape)*length(yrangeLandscape);
    X1DGM1 = zeros(length(feats1.IsRips), N);
    for ii = 1:length(feats1.IsRips)
        L = getRasterizedLandscape(feats1.IsRips{ii}, xrangeLandscape, yrangeLandscape);
        X1DGM1(ii, :) = L(:);
    end
    X2DGM1 = zeros(length(feats2.IsRips), N);
    for ii = 1:length(feats2.IsRips)
        L = getRasterizedLandscape(feats2.IsRips{ii}, xrangeLandscape, yrangeLandscape);
        X2DGM1(ii, :) = L(:);
    end
    
    %Euclidean/Geodesic
    X1EucGeo = feats1.Dists;
    X2EucGeo = feats2.Dists;
    
    n = length(feats1.IsRips);
    m = length(feats2.IsMorse);
    
    DRips = zeros(n, m);
    DEucGeo = zeros(n, m);
    DGH = zeros(n, m);
    DL2Stress = zeros(n, m);
    parfor ii = 1:n
        ii
        row = zeros(4, m);
        D1 = squareform(pdist(feats1.PointClouds{ii}));
        for jj = 1:m
            D2 = squareform(pdist(feats2.PointClouds{jj}));
            diff = D1(:) - D2(:);
            row(1, jj) = sqrt(sum(diff.*diff));%L2 Stress
            row(2, jj) = max(abs(diff));%Gromov-Hausdorff
        end
        for jj = 1:m
            diff = X1DGM1(ii, :) - X2DGM1(jj, :);
            row(3, jj) = sqrt(sum(diff.*diff));
            diff = X1EucGeo(ii, :) - X2EucGeo(jj, :);
            row(4, jj) = sqrt(sum(diff.*diff));
        end
        DRips(ii, :) = row(3, :);
        DEucGeo(ii, :) = row(4, :);
        DGH(ii, :) = row(2, :);
        DL2Stress(ii, :) = row(1, :);
    end

    %%%%%%%%%%% REAL NUMBER DISTANCE %%%%%%%%
    cutoff = 0.95;
    subplot(221);
    imagesc(DEucGeo);
    title('Euclidean/Geodesic');
    caxis([0, quantile(DEucGeo(:), cutoff)]);

    subplot(222);
    imagesc(DRips);
    title('Rips Landscapes');
    caxis([0, quantile(DRips(:), cutoff)]);

    subplot(223);
    imagesc(DGH);
    title('Gromov-Hausdorff');
    caxis([0, quantile(DGH(:), cutoff)]);

    subplot(224);
    imagesc(DL2Stress);
    title('L2 Metric Stress');
    caxis([0, quantile(DL2Stress(:), cutoff)]);

    %%%%%%%%%% BINARY THRESHOLD %%%%%%%%%%%%
    figure;
    cutoff = 0.11;
    subplot(221);
    imagesc(DEucGeo < quantile(DEucGeo(:), cutoff));
    title('Euclidean/Geodesic');

    subplot(222);
    imagesc(DRips < quantile(DRips(:), cutoff));
    title('Rips Landscapes');

    subplot(223);
    imagesc(DGH < quantile(DGH(:), cutoff));
    title('Gromov-Hausdorff');

    subplot(224);
    imagesc(DL2Stress < quantile(DL2Stress(:), cutoff));
    title('L2 Metric Stress');    
    
    save(outname, 'DEucGeo', 'DRips', 'DGH', 'DL2Stress');
end