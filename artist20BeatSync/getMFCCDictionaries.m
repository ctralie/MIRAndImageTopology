addpath(genpath('spams-matlab'));
start_spams

NArtists = 20;
NDictElems = 512;
NPoolDictElems = 32;
tracksTrain = 'a20-trn-tracks.list';
tracksTest = 'a20-tst-tracks.list';

files = textread(tracksTrain, '%s\n');
artistsMap = java.util.TreeMap();
songsByArtist = cell(1, NArtists);

for ii = 1:length(files)
    f = strsplit(files{ii}, '/');
    if isempty(artistsMap.get(f{1}))
        artistsMap.put(f{1}, artistsMap.size() + 1);
        idx = artistsMap.size() + 1;
        songsByArtist{idx} = {};
    end
    idx = artistsMap.get(f{1});
    songsByArtist{idx}{end+1} = files{ii};
end

% %Train each artist dictionary
Djs = cell(1, NArtists);
param.K = NDictElems;
param.numThreads = 4;
param.lambda = 0.15;
param.iter = 1000;

parfor ii = 1:NArtists
    f = strsplit(songsByArtist{ii}{1}, '/');
    fprintf(1, 'Training dictionary for %s\n', f{1});
    X = [];
    for kk = 1:length(songsByArtist{ii})
        kk
        X = [X; readhtk(sprintf('../DelaySeries/artist20/mfccs/%s.htk', songsByArtist{ii}{kk}))];
    end
    fprintf(1, 'Finished Loading %i MFCC elements\n', size(X, 1));

    Djs{ii} = mexTrainDL(X', param);%SPAMS takes the transpose of what pdist expects
end
save('MFCCDicts.mat', 'Djs');
load('MFCCDicts.mat');

D = cell2mat(Djs);%Full dictionary

%Now train the joint dictionaries for every artist
Phijs = cell(1, NArtists);
Ss = cell(1, NArtists);

%Sparse model with all of the samples on the full dictionary
paramSpm.K = size(D, 2);
paramSpm.numThreads = 4;
paramSpm.lambda = 0.15;
paramSpm.iter = -1;
paramSpm.verbose = 1;

%Parameters for inter-class dictionarys
paramPhi.K = NPoolDictElems;
paramPhi.numThreads = 4;
paramPhi.lambda = 1/NArtists;
paramPhi.iter = 1000;

for ii = 1:NArtists
    f = strsplit(songsByArtist{ii}{1}, '/');
    fprintf(1, 'Training sparse multi-class dictionary for %s\n', f{1});
    %Compute the "S" pooled sum matrix after sparse modeling
    %each song in the full dictionary
    S = zeros(NArtists, length(songsByArtist{ii}));
    for kk = 1:length(songsByArtist{ii})
        X = readhtk(sprintf('../DelaySeries/artist20/mfccs/%s.htk', songsByArtist{ii}{kk}));
        alpha = mexOMP(X', D, paramSpm);
        alpha = mean(abs(alpha), 2);%***Take the mean to normalize for song length
        alpha = reshape(alpha, NDictElems, NArtists);
        scorePooled = sum(alpha, 1);
        S(:, kk) = scorePooled';
        fprintf(1, 'Finished %i of %i\n', kk, length(songsByArtist{ii}));
    end
    Ss{ii} = S;
    %Learn the "Phi" dictionary
    Phijs{ii} = mexTrainDL(S, paramPhi);
end

save('MFCCDicts.mat', 'Djs', 'Phijs', 'Ss');