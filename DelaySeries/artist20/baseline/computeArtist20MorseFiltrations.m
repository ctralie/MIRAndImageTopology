%Compute morse filtrations based on MFCC averaged in 10 second windows
windowSize = 10;
filename = 'Artist20MorseDiagrams.mat';

addpath('../../../0DFiltrations');

trainset = '../lists/a20-trn-tracks.list';
testset = '../lists/a20-val-tracks.list';

trainFiles = textread(trainset, '%s\n');
testFiles = textread(testset, '%s\n');

trainArtistNames = labelsfor(trainset);
testArtistNames = labelsfor(testset);
artistNames = unique(trainArtistNames);
artistMap = java.util.HashMap;
for ii = 1:length(artistNames)
   artistMap.put(artistNames{ii}, ii); 
end

trainDiagrams = cell(length(trainFiles), 1);
trainArtists = zeros(length(trainFiles), 1);
testDiagrams = cell(length(testFiles), 1);
testArtists = zeros(length(testFiles), 1);

parfor ii = 1:length(trainFiles)
    Y = getSongPointCloud(trainFiles{ii}, windowSize);
    trainDiagrams{ii} = getMorseFiltered0DDiagrams(Y);
    trainArtists(ii) = artistMap.get(trainArtistNames{ii});
    fprintf(1, '==========  Finished %s  ==========\n', trainFiles{ii});
end

parfor ii = 1:length(testFiles)
    Y = getSongPointCloud(testFiles{ii}, windowSize);
    testDiagrams{ii} = getMorseFiltered0DDiagrams(Y);
    testArtists(ii) = artistMap.get(testArtistNames{ii});
    fprintf(1, '==========  Finished %s  ==========\n', testFiles{ii});
end

save(filename, 'artistNames', 'trainDiagrams', 'trainArtists', 'testDiagram', 'testArtists', 'windowSize');