function [DGH, DL2Stress] = plotFeatureSimilarities( s1prefix, s2prefix, BeatsPerWin, outname )
    addpath('../../');
    song1 = load(['../covers80/TempoEmbeddings/', s1prefix, '.mat']);
    song2 = load(['../covers80/TempoEmbeddings/', s2prefix, '.mat']);

    %Point center and sphere-normalize point clouds
    for ii = 1:length(song1.bts)-BeatsPerWin
        i1 = find(song1.SampleDelaysMFCC > song1.bts(ii));
        i2 = find(song1.SampleDelaysMFCC >= song1.bts(ii+BeatsPerWin));
        Y = song1.MFCC(i1:i2, :);
        Y = bsxfun(@minus, mean(Y), Y);
%         Y = bsxfun(@times, std(Y), Y);
        Norm = 1./(sqrt(sum(Y.*Y, 2)));
        Y = Y.*(repmat(Norm, [1 size(Y, 2)]));
        song1.PointClouds{ii} = Y;
    end
    for ii = 1:length(song2.bts)-BeatsPerWin
        i1 = find(song2.SampleDelaysMFCC > song2.bts(ii));
        i2 = find(song2.SampleDelaysMFCC >= song2.bts(ii+BeatsPerWin));
        Y = song2.MFCC(i1:i2, :);
        Y = bsxfun(@minus, mean(Y), Y);
%         Y = bsxfun(@times, std(Y), Y);
        Norm = 1./(sqrt(sum(Y.*Y, 2)));
        Y = Y.*(repmat(Norm, [1 size(Y, 2)]));
        song2.PointClouds{ii} = Y;
    end
    
    n = length(song1.PointClouds);
    m = length(song2.PointClouds);
    
    DGH = zeros(n, m);
    DL2Stress = zeros(n, m);
    parfor ii = 1:n
        ii
        row = zeros(4, m);
        D1 = squareform(pdist(song1.PointClouds{ii}));
        D1 = imresize(D1, [200, 200]);
        for jj = 1:m
            D2 = squareform(pdist(song2.PointClouds{jj}));
            D2 = imresize(D2, size(D1));
            diff = D1(:) - D2(:);
            row(1, jj) = sqrt(sum(diff.*diff));%L2 Stress
            row(2, jj) = max(abs(diff));%Gromov-Hausdorff
        end
        DGH(ii, :) = row(2, :);
        DL2Stress(ii, :) = row(1, :);
    end

    %%%%%%%%%%% REAL NUMBER DISTANCE %%%%%%%%
    cutoff = 0.95;

    subplot(211);
    imagesc(DGH);
    title('Gromov-Hausdorff');
    caxis([0, quantile(DGH(:), cutoff)]);

    subplot(212);
    imagesc(DL2Stress);
    title('L2 Metric Stress');
    caxis([0, quantile(DL2Stress(:), cutoff)]);

    %%%%%%%%%% BINARY THRESHOLD %%%%%%%%%%%%
    figure;
    cutoff = 0.01;

    subplot(221);
    imagesc(DGH < quantile(DGH(:), cutoff));
    title('Gromov-Hausdorff');

    subplot(222);
    imagesc(DL2Stress < quantile(DL2Stress(:), cutoff));
    title('L2 Metric Stress');    
    
    save(outname, 'DGH', 'DL2Stress');
end