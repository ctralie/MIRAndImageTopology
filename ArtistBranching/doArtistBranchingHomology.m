if exist('artistData.mat') == 0
    addpath('../GenrePersistence');
    addpath('../0DFiltrations');
    artistNames = {'Beatles', 'Eminem', 'Prince', 'Ramones', 'SeanPaul', 'Yes', 'Future', 'GratefulDead', 'Kesha', 'OwlCity'};
    artistData = {};
    %Load in data
    doMDS = 0;
    minSongs = 10000;
    for i = 1:length(artistNames)
       [~, ~, ~, artistData{i}] = loadArffFile(sprintf('%s.arff', artistNames{i}));
       if size(artistData{i}, 1) < minSongs
          minSongs = size(artistData{i}, 1); 
       end
    end
    %Make sure I'm comparing the same number of songs per artist for
    %consistency
    %fprintf('Randomly sampling %i songs per artist\n', minSongs);
    %for i = 1:length(artistNames)
    %   %Randomly sample the min number of songs
    %   artistData{i} = artistData{i}(randperm(minSongs), :); 
    %end
    save('artistData.mat', 'artistNames', 'artistData');
else
    load('artistData.mat');
end
disp('Finished loading artist data');

%Normalize all songs to the same data to the range [0, 1] in each dimension
%Calculate the min and max of each feature across all songs so this is
%consistent
minData = zeros(length(artistData), size(artistData{1}, 2));
maxData = zeros(length(artistData), size(artistData{1}, 2));
for i = 1:length(artistNames)
    minData(i, :) = min(artistData{i});
    maxData(i, :) = max(artistData{i});
end
minData = min(minData);
maxData = max(maxData);
for i = 1:length(artistNames)
    artistData{i} = bsxfun(@minus, artistData{i}, minData);
    artistData{i} = bsxfun(@times, artistData{i}, 1./(maxData+eps));
end
disp('Finished scaling data');


javaclasspath('jars/tda.jar');
import api.*;
tda = Tda();
%Do a sublevelset filtration to form the distance matrices for each artist
%Pick a random unit-norm direction in the feature space that's in the
%positive high dimensional quadrant
u = rand(size(artistData{1}, 2), 1);
u = u/(norm(u) + eps);

Is = {};
mstMasks = {};

for i = 1:length(artistNames)
    fprintf(1, 'Computing persistent homology for %s...\n', artistNames{i});
    %For each artist compute distance matrix that corresponds with the filtration
    %and compute the 0th persistence diagram
    %Step 1: Extract a sparse graph from the set of points by taking the
    %strongest 10% of edges only
    interDs = pdist(artistData{i});
    mstMask = getMSTMask(squareform(interDs));
    mstMasks{i} = mstMask;
    
    %Step 2: compute dot product of each point with the direction vector
    dotProds = artistData{i}*u;
    minI = min(dotProds);
    maxI = max(dotProds);

    %Step 3: Create the distance matrix corresponding to this filtration
    DRows = repmat(dotProds, [1, length(dotProds)]);
    DCols = repmat(dotProds', [length(dotProds), 1]);
    D = max(DRows, DCols).*mstMask;%Don't add the edges until both points have been added
    D(mstMask == 0) = inf;%Don't include edges that aren't in the MST
    %TODO: Make this all sparse
    %Also mask the edges by the graph that was extracted before
    %D = diag(dotProds);
    %D = squareform(pdist(artistData{i}));
    
    tda.RCA1( { 'settingsFile=data/cts.txt', 'supplyDataAs=distanceMatrix',sprintf('distanceBoundOnEdges=%g', 20)}, D );
    %I = get0DPersistence(D);
    I = tda.getResultsRCA1(0).getIntervals();
    Is{i} = I;
    %Do multidimensional scaling
    fprintf(1, 'Doing Multidimensional Scaling...\n');
    [Y,eigvals] = cmdscale(interDs);
    fprintf(1, 'Finished Multidimensional Scaling\n');
    Ys{i} = Y(:, 1:2);%Only store first 2 dimensions of Y
end

%Scale all of the songs from all of the artists together

%Now create plots
minI = inf;
maxI = -inf;
minDist = inf;
maxDist = -inf;
for i = 1:length(Is)
    minI = min(min(Is{i}(:)), minI);
    maxI = max(max(Is{i}(:)), maxI);
    minDist = min(min(Ys{i}(:)), minDist);
    maxDist = max(max(Ys{i}(:)), maxDist);
end

fHandle = fopen('imageTables.html', 'w');
fprintf(fHandle, '<table>\n');

PrintColumns = 2;
for i = 1:length(artistNames)
    %Plot Persistence Diagram
    subplot(1, 2, 1);
    plot(Is{i}(:, 1), Is{i}(:, 2), '.');
    sum(isnan(I(:, 2)))
    
    xlim([minI, maxI]);
    ylim([minI, maxI]);
    hold on;
    plot([minI, maxI], [minI, maxI], 'r');
    title(sprintf('%s 0D Persistence', artistNames{i}));
    axis equal;
    
    %Plot MST
    subplot(1, 2, 2);
    plotMST(mstMasks{i}, Ys{i});
    xlim([minDist, maxDist]);
    ylim([minDist, maxDist]);
    axis equal;
    title(sprintf('%s MST', artistNames{i}));
    
    print('-dpng', '-r100', sprintf('%s.png', artistNames{i}));
    if mod(i-1, PrintColumns) == 0
        fprintf(fHandle, '<tr>');
    end
    fprintf(fHandle, '<td><img src = "%s"%></td>', sprintf('%s.png', artistNames{i}));
    if mod(i-1, PrintColumns) == PrintColumns-1
       fprintf(fHandle, '</tr>\n');
    end
    clf;
end
fprintf(fHandle, '</table>');
fclose(fHandle);
