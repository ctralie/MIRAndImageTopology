%Compute 0D and 1D rips filtrations based on subsampled MFCCs averaged
%in 10 second windows
windowSize = 10;
globalSubsample = 15;%How much to downsample "global" 1D PCA point cloud
%to make 1D persistent homology more computationally feasible on the whole
%song

%The local 1D persistence parameters
%Hop by 1 second, do persistence in 5 second windows
MFCCSAMPLELEN = 0.016;
windowSizeLocal = 2;
windowLocal = floor(5/MFCCSAMPLELEN);
hopLocal = floor(2/MFCCSAMPLELEN);

addpath('../../../0DFiltrations');
addpath('../../');%Delay Series

filename = 'Artist20AllTDAFeatures.mat';

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
    Y = bsxfun(@minus, mean(Y, 1), Y);
    Y = bsxfun(@times, 1./std(Y), Y);
    %Subsampled version
    YGlobal = Y(1:globalSubsample:end, :);

    trainArtists(ii) = artistMap.get(trainArtistNames{ii});

    %Compute morse filtrations
    trainPDsMorse{ii} = getMorseFiltered0DDiagrams(Y, tda);
    
    %Compute global 1D filtration with birthing/killing edges
    [~, PD1Global, PD1GlobalBK] = getPersistenceDiagrams(YGlobal, tda);
    TrainPDs1Global{ii} = PD1Global;
    TrainPDs1GlobalBK{ii} = PD1GlobalBK;
    
    %Compute mini sliding window 1D filtrations
    YLocal = getSongPointCloud(trainFiles{ii}, windowSizeLocal, 1);
    YLocal = bsxfun(@minus, mean(YLocal, 1), YLocal);
    YLocal = bsxfun(@times, 1./std(YLocal), YLocal);
    TrainPDs1Local{ii} = getSlidingSliding1D(YLocal, hopLocal, windowLocal, tda);
    
    fprintf(1, '==========  Finished %s  ==========\n', trainFiles{ii});
end

TestPDsMorse = cell(NTest, 1);
TestPDs1Global = cell(NTest, 1);
TestPDs1GlobalBK = cell(NTest, 1);
TestPDs1Local = cell(NTest, 1);
testArtists = zeros(NTest, 1);

parfor ii = 1:NTest
    javaclasspath('jars/tda.jar');
    import api.*;
    tda = Tda();
    [Y, MFCCWindowSize] = getSongPointCloud(testFiles{ii}, windowSize, 1);
    Y = bsxfun(@minus, mean(Y, 1), Y);
    Y = bsxfun(@times, 1./std(Y), Y);
    %Subsampled version
    YGlobal = Y(1:globalSubsample:end, :);

    testArtists(ii) = artistMap.get(testArtistNames{ii});

    %Compute morse filtrations
    testPDsMorse{ii} = getMorseFiltered0DDiagrams(Y, tda);
    
    %Compute global 1D filtration with birthing/killing edges
    [~, PD1Global, PD1GlobalBK] = getPersistenceDiagrams(YGlobal, tda);
    TestPDs1Global{ii} = PD1Global;
    TestPDs1GlobalBK{ii} = PD1GlobalBK;
    
    %Compute mini sliding window 1D filtrations
    YLocal = getSongPointCloud(testFiles{ii}, windowSizeLocal, 1);
    YLocal = bsxfun(@minus, mean(YLocal, 1), YLocal);
    YLocal = bsxfun(@times, 1./std(YLocal), YLocal);
    TestPDs1Local{ii} = getSlidingSliding1D(YLocal, hopLocal, windowLocal, tda);
    
    fprintf(1, '==========  Finished %s  ==========\n', testFiles{ii});
end


save(filename, 'artistNames', ...
    'TrainPDsMorse', 'TrainPDs1Global', 'TrainPDs1GlobalBK', 'TrainPDs1Local', 'trainArtists', ...
    'TestPDsMorse', 'TestPDs1Global', 'TestPDs1GlobalBK', 'TestPDs1Local', 'testArtists', ...
    'windowSize', 'globalSubsample', 'windowLocal', 'hopLocal', 'windowSizeLocal');