addpath(genpath('spams-matlab'));
start_spams

NArtists = 20;
NDictElems = 512;
tracksTrain = 'a20-trn-tracks.list';
tracksTest = 'a20-tst-tracks.list';

files = textread(tracksTrain, '%s\n');
artistsMap = java.util.TreeMap();
artistNames = cell(1, NArtists);

for ii = 1:length(files)
    f = strsplit(files{ii}, '/');
    if isempty(artistsMap.get(f{1}))
        artistsMap.put(f{1}, artistsMap.size() + 1);
        artistNames{artistsMap.size()} = f{1};
    end
end

files = textread(tracksTest, '%s\n');
songsByArtist = cell(1, NArtists);
for ii = 1:length(files)
    f = strsplit(files{ii}, '/');
    idx = artistsMap.get(f{1});
    songsByArtist{idx}{end+1} = files{ii};
end

%Setup full dictionary
load('MFCCDicts');
D = cell2mat(Djs);
param.K = NDictElems*NArtists;
param.numThreads = 4;
param.lambda = 0.15;
param.iter = -1;

C = zeros(NArtists, NArtists);%Confusion Matrix
for ii = 1:NArtists
    f = strsplit(songsByArtist{ii}{1}, '/');
    fprintf(1, 'Testing songs in %s\n', f{1});

    for kk = 1:length(songsByArtist{ii})
        X = readhtk(sprintf('../DelaySeries/artist20/mfccs/%s.htk', songsByArtist{ii}{kk}));
        alpha = mexOMP(X', D, param);
        alpha = sum(abs(alpha), 2);
        alpha = reshape(alpha, NDictElems, NArtists);
        scorePooled = sum(alpha, 1);
%         plot(scorePooled);
%         set(gca, 'XTick', 1:NArtists);
%         set(gca, 'XTickLabel', artistNames);
        [~, jj] = max(scorePooled);%argmax
        f = strsplit(songsByArtist{ii}{kk}, '/');
        fprintf(1, '%s classified as %s\n', f{1}, artistNames{jj});
        C(ii, jj) = C(ii, jj) + 1;
    end
    fprintf(1, '%g Percent Correct So Far\n', 100*sum(diag(C))/sum(C(:)));
end

artistNamesDisp = cell(size(artistNames));
for ii = 1:length(artistNames)
    name = artistNames{ii};
    newLen = min(length(name), 4);
    artistNamesDisp{ii} = name(1:newLen);
end

imagesc(C);
set(gca, 'YLim', [0 NArtists+1], 'YTick', 1:NArtists, 'YTickLabel', artistNamesDisp);
set(gca, 'XLim', [0 NArtists+1], 'XTick', 1:NArtists, 'XTickLabel', artistNamesDisp);
title(sprintf('%g Percent Correct', 100*sum(diag(C))/sum(C(:))));