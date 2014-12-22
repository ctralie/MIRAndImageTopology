list1 = 'covers32k/list1.list';
list2 = 'covers32k/list2.list';

files1 = textread(list1, '%s\n');
files2 = textread(list2, '%s\n');

features1 = cell(1, length(files1));
features2 = cell(1, length(files2));

cutoffidx = 11;

for ii = 1:length(features1)
    feats = load(sprintf('ftrsgeom/%s.mat', files1{ii}));
    hists = feats.TimeLoopHists;
    hists = reshape(hists, [length(hists), 1]);
    features1{ii} = cell2mat(hists)';
    features1{ii} = features1{ii}(cutoffidx:end, :);
end

for ii = 1:length(features2)
    feats = load(sprintf('ftrsgeom/%s.mat', files2{ii}));
    hists = feats.TimeLoopHists;
    hists = reshape(hists, [length(hists), 1]);
    features2{ii} = cell2mat(hists)';
    features2{ii} = features2{ii}(cutoffidx:end, :);
end

% for ii = 1:length(features1)
%     subplot(2, 1, 1);
%     imagesc(sqrt(features1{ii}));
%     title(files1{ii});
%     subplot(2, 1, 2);
%     imagesc(sqrt(features2{ii}));
%     title(files2{ii});
%     print('-dpng', '-r100', sprintf('%i.png', ii));
% end

R = zeros(length(features1), length(features2));
for ii = 1:length(features1)
    for jj = 1:length(features2)
        thiscorr = shapexcorr(sqrt(features1{ii}), sqrt(features2{jj}));
        R(ii, jj) = max(thiscorr(:));
        fprintf(1, '(%i, %i): %g\n', ii, jj, R(ii, jj));
    end
end

[~, idx] = max(R, [], 2);
sum(idx' == 1:80)