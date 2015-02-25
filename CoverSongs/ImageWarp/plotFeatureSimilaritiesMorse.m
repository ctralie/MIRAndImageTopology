function [D, DGMs1, DGMs2] = plotFeatureSimilaritiesMorse( s1prefix, s2prefix, NBars )
    addpath('../../TDAMex');
    addpath('../../');
    song1 = load(['../covers80/TempoEmbeddings/', s1prefix, '.mat']);
    song2 = load(['../covers80/TempoEmbeddings/', s2prefix, '.mat']);

    N = length(song1.bts)-1;
    M = length(song2.bts)-1;    
    
    DGMs1 = cell(1, N);
    SortedBars1 = zeros(N, NBars);
    %Point center and sphere-normalize point clouds
    for ii = 1:N
        i1 = find(song1.SampleDelaysMFCC > song1.bts(ii));
        i2 = find(song1.SampleDelaysMFCC >= song1.bts(ii+1));
        D = getScaledDist(song1.MFCC(i1:i2, :), 1);
        D = imresize(D, [200, 200]);
        [I, Gens] = morseFiltration2DMex(D);
        fprintf(1, '%i: %i bars\n', ii, size(I, 1));
        DGMs1{ii} = I;
        if ~isempty(I)
            I = sort(I(:, 2) - I(:, 1), 'descend');
            nnonzero = min(size(I, 1), NBars);
            SortedBars1(ii, 1:nnonzero) = I(1:nnonzero);
        end
    end
    
    DGMs2 = cell(1, M);
    SortedBars2 = zeros(M, NBars);
    for ii = 1:M
        i1 = find(song2.SampleDelaysMFCC > song2.bts(ii));
        i2 = find(song2.SampleDelaysMFCC >= song2.bts(ii+1));
        D = getScaledDist(song2.MFCC(i1:i2, :), 1);
        D = imresize(D, [200, 200]);
        [I, Gens] = morseFiltration2DMex(D);
        fprintf(1, '%i: %i bars\n', ii, size(I, 1));
        if ~isempty(I)
            I = sort(I(:, 2) - I(:, 1), 'descend');
            nnonzero = min(size(I, 1), NBars);
            SortedBars2(ii, 1:nnonzero) = I(1:nnonzero);
        end        
        DGMs2{ii} = I;      
    end
    
    N = length(DGMs1);
    M = length(DGMs2);
    D = zeros(N, M);
    for ii = 1:N
        fprintf(1, '%i of %i\n', ii, N);
        row = zeros(1, M);
        bars1 = SortedBars1(ii, :);
        parfor jj = 1:M
            %[~, row(jj)] = getWassersteinDist(DGMs1{ii}, DGMs2{jj});
            row(jj) = sqrt(sum((bars1-SortedBars2(jj, :)).^2));
        end
        D(ii, :) = row;
    end
end