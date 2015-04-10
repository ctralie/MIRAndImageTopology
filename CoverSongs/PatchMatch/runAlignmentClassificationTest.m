addpath('../SequenceAlignment');
FolderPrefix = 'AllCrossSimilarities8';
D = zeros(80, 80);

for ii = 1:80
    load(sprintf('%s/%i.mat', FolderPrefix, ii));
    fprintf(1, 'Doing %i of %i...\n', ii, 80);
    for jj = 1:80
        M = double(full(Ms{jj}));
        D(ii, jj) = sqrt(size(M, 2))/swalignimp(M);
    end
end

[~, idx] = min(D, [], 2);
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
