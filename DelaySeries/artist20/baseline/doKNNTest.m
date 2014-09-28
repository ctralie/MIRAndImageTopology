k = 5;
startbar = 1;
endbar = 20;
load('Artist20RipsDiagrams');
NArtists = length(artistNames);

trainset = '../lists/a20-trn-tracks.list';
testset = '../lists/a20-val-tracks.list';

trainFiles = textread(trainset, '%s\n');
NTrain = length(trainFiles);
testFiles = textread(testset, '%s\n');
NTest = length(testFiles);

XTrain = zeros(NTrain, endbar-startbar+1);
XTest = zeros(NTest, endbar-startbar+1);

for ii = 1:NTrain
    XTrain(ii, :) = getSortedBars(TrainPDs1{ii}, startbar, endbar, 0);
end

for ii = 1:NTest
    XTest(ii, :) = getSortedBars(TestPDs1{ii}, startbar, endbar, 0); 
end

C = zeros(NArtists, NArtists);
D = squareform(pdist([XTrain; XTest]));
Y = cmdscale(D);


D = D(NTrain+1:end, 1:NTrain);

for ii = 1:NTest
   [~, idx] = min(D(ii, :));
   C(testArtists(ii), trainArtists(idx)) = C(testArtists(ii), trainArtists(idx)) + 1;
end

%Accuracy
sum(diag(C)/sum(C(:)))

%Mean Plot
MeanTrain = zeros(NArtists, endbar - startbar + 1);

set(0,'DefaultAxesLineStyleOrder','-|--|-.');

for ii = 1:NArtists
    MeanTrain(ii, :) = mean(XTrain(trainArtists == ii, :));
end

plot(MeanTrain');
legend(artistNames);
xlabel('Bar Number');
ylabel('Lifetime');
title('Top Lifetime Bars for All Artists');

%Box plots for different bars


%Top persistent bar
[topPersistenceVals, idx] = sort(XTrain(:, 1), 'descend');
topPersistenceSorted = cell(NTrain, 1);
for ii = 1:NTrain
    topPersistenceSorted{ii} = trainFiles{idx(ii)};
end