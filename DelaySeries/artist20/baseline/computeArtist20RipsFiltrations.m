%Compute 0D and 1D rips filtrations based on subsampled MFCCs averaged
%in 10 second windows
windowSize = 10;
DownsampleFac = 15;
filename = 'Artist20MorseDiagrams.mat';

addpath('../../../0DFiltrations');

trainset = '../lists/a20-trn-tracks.list';
testset = '../lists/a20-val-tracks.list';

trainFiles = textread(trainset, '%s\n');
NTrain = length(trainFiles);
testFiles = textread(testset, '%s\n');
NTest = length(testFiles);

trainArtistNames = labelsfor(trainset);
testArtistNames = labelsfor(testset);
artistNames = unique(trainArtistNames);
artistMap = java.util.HashMap;
for ii = 1:length(artistNames)
   artistMap.put(artistNames{ii}, ii); 
end

TrainPDs0 = cell(NTrain, 1);
TrainPDs1 = cell(NTrain, 1);
TrainPDs1BK = cell(NTrain, 1);
trainArtists = zeros(NTrain, 1);

parfor ii = 1:NTrain
   Y = getSongPointCloud(trainFiles{ii}, windowSize);
   trainArtists(ii) = artistMap.get(trainArtistNames{ii});
   
   [PD0, PD1, PD1BK] = getPersistenceDiagrams(Y(1:DownsampleFac:end, :));

   TrainPDs0{ii} = PD0;
   TrainPDs1{ii} = PD1;
   TrainPDs1BK{ii} = PD1BK;
   fprintf(1, '==========  Finished %s  ==========\n', trainFiles{ii});
end


TestPDs0 = cell(NTest, 1);
TestPDs1 = cell(NTest, 1);
TestPDs1BK = cell(NTest, 1);
testArtists = zeros(NTest, 1);

parfor ii = 1:NTest
   Y = getSongPointCloud(testFiles{ii}, windowSize);
   testArtists(ii) = artistMap.get(testArtistNames{ii});
   
   [PD0, PD1, PD1BK] = getPersistenceDiagrams(Y(1:DownsampleFac:end, :));

   TestPDs0{ii} = PD0;
   TestPDs1{ii} = PD1;
   TestPDs1BK{ii} = PD1BK;
   fprintf(1, '==========  Finished %s  ==========\n', testFiles{ii});
end


save(filename, 'artistNames', 'TrainPDs0', 'TrainPDs1', 'TrainPDs1BK',  ...
    'trainArtists', 'TestPDs0', 'TestPDs1', 'TestPDs1BK', 'testArtists', 'windowSize', 'DownsampleFac');