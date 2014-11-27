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

%Parameters for inter-class dictionarys
paramPhi.K = NPoolDictElems;
paramPhi.numThreads = 4;
paramPhi.lambda = 1/NArtists;
paramPhi.iter = 1000;

CLevel1 = zeros(NArtists, NArtists);%Confusion Matrix level 1
CLevel2 = zeros(NArtists, NArtists);%Confusion Matrix level 2
for ii = 1:NArtists
    f = strsplit(songsByArtist{ii}{1}, '/');
    fprintf(1, 'Testing songs in %s\n', f{1});

    for kk = 1:length(songsByArtist{ii})
        X = readhtk(sprintf('../DelaySeries/artist20/mfccs/%s.htk', songsByArtist{ii}{kk}));
        alpha = mexOMP(X', D, param);
        alpha = mean(abs(alpha), 2);%***Take the mean to normalize for song length
        alpha = reshape(alpha, NDictElems, NArtists);
        scorePooled = full(sum(alpha, 1));
        
        %Level 1 classification
        [~, jj] = max(scorePooled);%argmax
        f = strsplit(songsByArtist{ii}{kk}, '/');
        fprintf(1, 'Level 1: %s classified as %s\n', f{1}, artistNames{jj});
        CLevel1(ii, jj) = CLevel1(ii, jj) + 1;
        
        %Level 2 classification
        minObj = inf;
        minClass = 1;
        for jj = 1:length(Phijs)
            alpha = mexOMP(scorePooled', Phijs{jj}, paramPhi);
            fit = Phijs{jj}*alpha - scorePooled';
            fit = sum(fit.*fit);
            thisObj = 0.5*fit + paramPhi.lambda*sum(abs(alpha));
            if thisObj < minObj
                minObj = thisObj;
                minClass = jj;
            end
        end
        CLevel2(ii, minClass) = CLevel2(ii, minClass) + 1;
        fprintf(1, 'Level 2: %s classified as %s\n', f{1}, artistNames{minClass});
    end
    fprintf(1, 'Level 1 %g Percent Correct So Far\n', 100*sum(diag(CLevel1))/sum(CLevel1(:)));
    fprintf(1, 'Level 2 %g Percent Correct So Far\n', 100*sum(diag(CLevel2))/sum(CLevel2(:)));
end

artistNamesDisp = cell(size(artistNames));
for ii = 1:length(artistNames)
    name = artistNames{ii};
    newLen = min(length(name), 4);
    artistNamesDisp{ii} = name(1:newLen);
end

imagesc(CLevel1);
set(gca, 'YLim', [0 NArtists+1], 'YTick', 1:NArtists, 'YTickLabel', artistNamesDisp);
set(gca, 'XLim', [0 NArtists+1], 'XTick', 1:NArtists, 'XTickLabel', artistNamesDisp);
title(sprintf('Level 1 %g Percent Correct', 100*sum(diag(CLevel1))/sum(CLevel1(:))));

figure;
imagesc(CLevel2);
set(gca, 'YLim', [0 NArtists+1], 'YTick', 1:NArtists, 'YTickLabel', artistNamesDisp);
set(gca, 'XLim', [0 NArtists+1], 'XTick', 1:NArtists, 'XTickLabel', artistNamesDisp);
title(sprintf('Level 2 %g Percent Correct', 100*sum(diag(CLevel2))/sum(CLevel2(:))));