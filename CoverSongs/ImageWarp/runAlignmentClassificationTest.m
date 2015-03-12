addpath('../SequenceAlignment');
load('../CurvatureWarp/AllDissimilarities8');
D = zeros(80, 80);

thresh = 0.15;
hist = load('BinarySimilarityHistL2.mat');
cdf = cumsum(hist.hist);
cutoff = hist.bins(find(cdf > thresh, 1));

for ii = 1:80
    ii
    for jj = 1:80
        cutoff = quantile(Ms{ii, jj}(:), 0.05);
        M = double(Ms{ii, jj} < cutoff);
        D(ii, jj) = swalignimp(M)/sum(size(M));
    end
end

[~, idx] = max(D, [], 2);
imagesc(D);
colormap('gray');
hold on;
equalidx = 1:80;
equalidx = equalidx(idx' == 1:80);
for ii = 1:length(idx)
    if ii == idx(ii)
        scatter(idx(ii), ii, 30, 'g', 'fill');
    else
        scatter(idx(ii), ii, 30, 'r', 'fill');
        scatter(ii, ii, 10, 'b', 'fill');
    end
end
correct = 1:80;
equalidx
title(sprintf('%i of %i correct', sum(1:80 == idx'), 80)); 
