%Compute 0D and 1D rips filtrations based on subsampled MFCCs averaged
%in 10 second windows
windowSize = 10;
globalSubsample = 15;
addpath('../../../0DFiltrations');

filename = 'Artist20RipsDiagrams.mat';

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

TrainPDsMorse = cell(NTrain, 1);
TrainPDs1Global = cell(NTrain, 1);
TrainPDs1GlobalBK = cell(NTrain, 1);
TrainPDs1Local = cell(NTrain, 1);
trainArtists = zeros(NTrain, 1);

parfor ii = 1:NTrain
    javaclasspath('jars/tda.jar');
    import api.*;
    tda = Tda();
    [Y, MFCCWindowSize] = getSongPointCloud(trainFiles{ii}, windowSize, 1);
    %Subsampled version
    YGlobal = getSongPointCloud(trainFiles{ii}, windowSize, globalSubsample);
    trainArtists(ii) = artistMap.get(trainArtistNames{ii});

    %Compute global persistence diagram with birthing/killing edges
    [~, PD1Global, PD1GlobalBK] = getPersistenceDiagrams(YGlobal, tda);
    TrainPDs1Global{ii} = PD1Global;
    TrainPDs1GlobalBK{ii} = PD1GlobalBK;

    %Compute morse filtrations
    trainDiagrams{ii} = getMorseFiltered0DDiagrams(Y);
    
    %Compute sliding window 1D filtrations

    fprintf(1, '==========  Finished %s  ==========\n', trainFiles{ii});
end


TestPDs0 = cell(NTest, 1);
TestPDs1 = cell(NTest, 1);
TestPDs1BK = cell(NTest, 1);
testArtists = zeros(NTest, 1);

parfor ii = 1:NTest
    javaclasspath('jars/tda.jar');
    import api.*;
   tda = Tda();
   Y = getSongPointCloud(testFiles{ii}, windowSize, globalSubsample);
   testArtists(ii) = artistMap.get(testArtistNames{ii});
   
   [PD0, PD1, PD1BK] = getPersistenceDiagrams(Y, tda);
   
   TestPDs0{ii} = PD0;
   TestPDs1{ii} = PD1;
   TestPDs1BK{ii} = PD1BK;
   fprintf(1, '==========  Finished %s  ==========\n', testFiles{ii});
end


save(filename, 'artistNames', 'TrainPDs0', 'TrainPDs1', 'TrainPDs1BK',  ...
    'trainArtists', 'TestPDs0', 'TestPDs1', 'TestPDs1BK', 'testArtists', 'windowSize', 'subsample');