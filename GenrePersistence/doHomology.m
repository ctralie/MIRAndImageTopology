%Load in data
NSubSamples = 10000;
doSparseMatrix = 0;
doMDS = 0;
[attributeNames, attributeTypes, nominalValues, data, songInfo, songInfoNums] = loadArffFile('songs6Features.arff');

if NSubSamples > 0
    songSamples = randperm(size(data, 1));
    data = data(songSamples(1:NSubSamples), :);%Downample data
    songInfo = songInfo(songSamples(1:NSubSamples), :);
    songInfoNums = songInfoNums(songSamples(1:NSubSamples), :);
end
%Normalize data to the range [0, 1] in each dimension
N = size(data, 1);
minData = min(data);
data = bsxfun(@minus, data, minData);
maxData = max(data);
data = bsxfun(@times, data, 1./(maxData+eps));
%Calculate the euclidean pairwise distance row vector
disp('Calculating distance matrix');
D = pdist(data, 'euclidean');
disp('Finished calculating distance matrix');

if doMDS == 1
    %Do multidimensional scaling
    [Y,eigvals] = cmdscale(D);
    gscatter(Y(:, 1), Y(:, 2), cell2mat(songInfoNums(:, 1)) );
    genreNames = nominalValues(end-3, :);
    genreNames = genreNames{1};
    legend(genreNames);
end

disp('Getting max dist');
%maxDist = quantile(D, 0.05) %Only include the top 5% of distances
maxDist = 0.09;
minDist = 0;
disp('Finished getting max dist');
DSparse = [0 0 0];
if doSparseMatrix == 1
    %Make a sparse distance matrix
    minDist = min(D);
    index = 1;
    DCount = 1;
    %Store upper triangular part in sparse matrix
    disp('Creating sparse distance matrix');
    for i = 1:N
       for j = i+1:N
           if D(DCount) < maxDist
              DSparse(index, :) = [i j D(DCount)];
              index = index + 1;
           end
           DCount = DCount + 1;
       end
    end
    disp('Finished creating sparse distance matrix');
end
clear D;

disp('Starting Persistent Homology');
javaclasspath('jars/tda.jar');
import api.*;
tda = Tda();
if doSparseMatrix == 1
    tda.RCA1( { 'settingsFile=data/cts.txt', 'supplyDataAs=sparseMatrix',sprintf('distanceBoundOnEdges=%g', maxDist)}, DSparse );
else
    %tda.RCA1( { 'settingsFile=data/cts.txt', 'supplyDataAs=distanceMatrix',sprintf('distanceBoundOnEdges=%g', maxDist)}, squareform(D) );
    tda.RCA1( { 'settingsFile=data/cts.txt', 'supplyDataAs=pointCloud', sprintf('distanceBoundOnEdges=%g', maxDist)}, data );
end
disp('Finished Persistent Homology');
I = tda.getResultsRCA1(0).getIntervals();
J = tda.getResultsRCA1(1).getIntervals();
figure;
plot(I(:, 1), I(:, 2), '.');
xlim([minDist, maxDist]);
ylim([minDist, maxDist]);
axis square;
title('0D Persistence Diagram');

figure;
plot(J(:, 1), J(:, 2), '.');
xlim([minDist, maxDist]);
ylim([minDist, maxDist]);
hold on;
plot([minDist, maxDist], [minDist, maxDist], 'r');
axis square;
title('1D Persistence Diagram');