TYPE_TIMELOOPHISTSCORR = 1;
TYPE_LANDSCAPEKMEANSEDIT = 2;
TYPE_DGMDTW = 3;
TYPE_LANDSCAPEKMEANS_SW = 4;
TYPE = TYPE_LANDSCAPEKMEANS_SW;

RECOMPUTE_STRINGS = 0;

C = load('KMeans10.mat');
C = C.C;
xrangeLandscape = linspace(0, 2, 50);
yrangeLandscape = linspace(0, 0.6, 50);

list1 = 'covers32k/list1.list';
list2 = 'covers32k/list2.list';

files1 = textread(list1, '%s\n');
files2 = textread(list2, '%s\n');

features1 = cell(1, length(files1));
features2 = cell(1, length(files2));

if TYPE == TYPE_TIMELOOPHISTSCORR
    cutoffidx = 11;

    parfor ii = 1:length(features1)
        feats = load(sprintf('ftrsgeom/%s.mat', files1{ii}));
        hists = feats.TimeLoopHists;
        hists = reshape(hists, [length(hists), 1]);
        features1{ii} = cell2mat(hists)';
        features1{ii} = features1{ii}(cutoffidx:end, :);
    end

    parfor ii = 1:length(features2)
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
        parfor jj = 1:length(features2)
            thiscorr = shapexcorr(sqrt(features1{ii}), sqrt(features2{jj}));
            R(ii, jj) = max(thiscorr(:));
            fprintf(1, '(%i, %i): %g\n', ii, jj, R(ii, jj));
        end
    end    
    [~, idx] = min(R, [], 2);
    sum(idx' == 1:80)
elseif TYPE == TYPE_LANDSCAPEKMEANSEDIT
    parfor ii = 1:length(features1)
        ii
        feats = load(sprintf('ftrsgeom/%s.mat', files1{ii}));
        features1{ii} = getBeatShapeString(feats.Is, C, xrangeLandscape, yrangeLandscape);
    end

    parfor ii = 1:length(features2)
        ii
        feats = load(sprintf('ftrsgeom/%s.mat', files2{ii}));
        features2{ii} = getBeatShapeString(feats.Is, C, xrangeLandscape, yrangeLandscape);
    end
    R = zeros(length(features1), length(features2));
    for ii = 1:length(features1)
        parfor jj = 1:length(features2)
            R(ii, jj) = getEditDist(features1{ii}, features2{jj}, 2);
            fprintf(1, '(%i, %i): %g\n', ii, jj, R(ii, jj));
        end
    end
    [~, idx] = max(R, [], 2);
    sum(idx' == 1:80)
    scatter(idx(ii), ii, 30, 'g', 'fill');
    save('R.mat', 'R');
elseif TYPE == TYPE_DGMDTW
    for ii = 1:length(features1)
        ii
        feats = load(sprintf('ftrsgeom/%s.mat', files1{ii}));
        features1{ii} = feats.Is;
        for kk = 1:length(features1{ii})
            if (isempty(features1{ii}{kk}))
                continue;
            end
            [~, idx] = sort(features1{ii}{kk}(:, 2) - features1{ii}{kk}(:, 1), 'descend');
            features1{ii}{kk} = features1{ii}{kk}(idx, :);
        end
    end
    for ii = 1:length(features2)
        ii
        feats = load(sprintf('ftrsgeom/%s.mat', files2{ii}));
        features2{ii} = feats.Is;
        for kk = 1:length(features2{ii})
            if (isempty(features2{ii}{kk}))
                continue;
            end            
            [~, idx] = sort(features2{ii}{kk}(:, 2) - features2{ii}{kk}(:, 1), 'descend');
            features2{ii}{kk} = features2{ii}{kk}(idx, :);
        end
    end
    R = zeros(length(features1), length(features2));
    for ii = 1:length(features1)
        parfor jj = 1:length(features2)
            fprintf(1, 'Doing (%i, %i)\n', ii, jj);
            R(ii, jj) = getDTWDist(features1{ii}, features2{jj}, 2);
            fprintf(1, '(%i, %i): %g\n', ii, jj, R(ii, jj));
        end
    end
    [~, idx] = min(R, [], 2);
    sum(idx' == 1:80)
    scatter(idx(ii), ii, 30, 'g', 'fill');
    save('R.mat', 'R');
elseif TYPE == TYPE_LANDSCAPEKMEANS_SW
    SMatch = 2;
    SMismatch = -3;
    SMatrix = SMatch*eye(size(C, 1)) - SMismatch;
    SMatrix = SMatrix + SMismatch;
    GapOpen = -2;
    GapExtension = -2;
    for ii = 1:length(features1)
        ii
        filename = sprintf('ftrsgeom/%s_2.mat', files1{ii});
        vars = whos('-file', filename);
        if ~ismember('beatString', {vars.name}) || RECOMPUTE_STRINGS
            feats = load(filename, 'IsRips');
            beatString = getBeatShapeString(feats.IsRips, C, xrangeLandscape, yrangeLandscape);
            save(filename, 'beatString', '-append');
            features1{ii} = beatString;
        else
            beatString = load(filename, 'beatString');
            features1{ii} = beatString.beatString;
        end
    end

    for ii = 1:length(features2)
        ii
        filename = sprintf('ftrsgeom/%s_2.mat', files2{ii});
        vars = whos('-file', filename);
        if ~ismember('beatString', {vars.name}) || RECOMPUTE_STRINGS
            feats = load(filename, 'IsRips');
            beatString = getBeatShapeString(feats.IsRips, C, xrangeLandscape, yrangeLandscape);
            save(filename, 'beatString', '-append');
            features2{ii} = beatString;
        else
            beatString = load(filename, 'beatString');
            features2{ii} = beatString.beatString;
        end
    end
    R = zeros(length(features1), length(features2));
    for ii = 1:length(features1)
        parfor jj = 1:length(features2)
            N = length(features1{ii});
            M = length(features2{ii});
            R(ii, jj) = nwalign(features1{ii}, features2{jj}, 'ScoringMatrix', SMatrix);%, ...
            %    'GapOpen', GapOpen, 'ExtendGap', GapExtension);
            fprintf(1, '(%i, %i): %g\n', ii, jj, R(ii, jj));
        end
    end
    [~, idx] = max(R, [], 2);
    sum(idx' == 1:80)
    scatter(idx(ii), ii, 30, 'g', 'fill');
    save('R.mat', 'R');
end

imagesc(R);
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
title(sprintf('%i of %i correct', sum(1:80 == idx'), 80));