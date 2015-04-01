addpath('../../');
list1 = '../covers80/covers32k/list1.list';
list2 = '../covers80/covers32k/list2.list';

files1 = textread(list1, '%s\n');
files2 = textread(list2, '%s\n');
N = length(files1);

dim = 200;
BeatsPerWin = 8;
beatDownsample = 2;
NBars = 2;

LandscapeRes = 50;
xrangeLandscape = linspace(0, 2, LandscapeRes);
yrangeLandscape = linspace(0, 0.6, LandscapeRes);

dirname = sprintf('AllRips%i_%i', BeatsPerWin, beatDownsample);

LandscapesOrig = cell(1, N);
for ii = 1:N
    fprintf(1, 'Doing %s...\n', files1{ii});
    DGMs = load(sprintf('%s/%i.mat', dirname, ii));
    DGMs = DGMs.DGMs;
    D = zeros(length(DGMs), LandscapeRes*LandscapeRes*BeatsPerWin);
    for jj = 1:length(DGMs)
        for kk = 1:BeatsPerWin
            L = getRasterizedLandscape(DGMs{jj, kk}, xrangeLandscape, yrangeLandscape);
            D(jj, (kk-1)*LandscapeRes*LandscapeRes + (1:LandscapeRes*LandscapeRes)) = L(:)';
        end
    end
    LandscapesOrig{ii} = D;
end

LandscapesCover = cell(1, N);
parfor ii = 1:N
    fprintf(1, 'Doing %s...\n', files2{ii});
    DGMs = load(sprintf('%s/%i.mat', dirname, ii+80));
    DGMs = DGMs.DGMs;
    D = zeros(length(DGMs), LandscapeRes*LandscapeRes*BeatsPerWin);
    for jj = 1:length(DGMs)
        for kk = 1:BeatsPerWin
            L = getRasterizedLandscape(DGMs{jj, kk}, xrangeLandscape, yrangeLandscape);
            D(jj, (kk-1)*LandscapeRes*LandscapeRes + (1:LandscapeRes*LandscapeRes)) = L(:)';
        end
    end
    LandscapesCover{ii} = D;
end

if ~exist(sprintf('AllDissimilarities%i_%i', BeatsPerWin, beatDownsample))
    mkdir(sprintf('AllDissimilarities%i_%i', BeatsPerWin, beatDownsample));
end
for ii = 1:N
    filename = sprintf('AllDissimilarities%i_%i/%i.mat', BeatsPerWin, beatDownsample, ii);
    if exist(filename)
        continue;
    end
    tic
    D = LandscapesCover{ii};
    Ms = cell(1, N);
    parfor jj = 1:N
        Ms{jj} = pdist2(LandscapesOrig{jj}, D);
        fprintf(1, '.');
    end
    save(filename, 'Ms');
    toc
    fprintf(1, '\n');
end

%%Unwrap landscapes and make a video
% idx = 76;
% ii = 1;
% D = LandscapesOrig{idx};
% for ii = 1:size(D, 1)
%     for kk = 1:BeatsPerWin
%         dgm = reshape(D(ii, (kk-1)*LandscapeRes*LandscapeRes + (1:LandscapeRes*LandscapeRes)), ...
%             LandscapeRes, LandscapeRes);
%         subplot(3, 3, kk);
%         imagesc(flipud(dgm));
%         axis off;
%         title(sprintf('%i', kk));
%     end
%     print('-dpng', '-r100', sprintf('%i.png', ii));
% end