if exist('artistData.mat') == 0
    addpath('../GenrePersistence');
    artistNames = {'Beatles', 'Eminem', 'Prince', 'Ramones', 'SeanPaul', 'Yes'};
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
    fprintf('Randomly sampling %i songs per artist\n', minSongs);
    for i = 1:length(artistNames)
       %Randomly sample the min number of songs
       artistData{i} = artistData{i}(randperm(minSongs), :); 
    end
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

%Figure out the threshold for the bottom 5% of distances
D = [];
for i = 1:length(artistNames)
   D = [D pdist(artistData{i})];
end
distanceCutoff = quantile(D, 0.1);


javaclasspath('jars/tda.jar');
import api.*;
tda = Tda();
%Do a sublevelset filtration to form the distance matrices for each artist
%Pick a random unit-norm direction in the feature space that's in the
%positive high dimensional quadrant
u = rand(size(artistData{1}, 2), 1);
u = u/(norm(u) + eps);
for i = 1:length(artistNames)
    fprintf(1, 'Computing persistent homology for %s...\n', artistNames{i});
    %For each artist compute distance matrix that corresponds with the filtration
    %and compute the 0th persistence diagram
    %Step 1: Extract a sparse graph from the set of points by taking the
    %strongest 10% of edges only
    interDs = pdist(artistData{i});
    toKeep = squareform(interDs) < distanceCutoff;
    
    %Step 2: compute dot product of each point with the direction vector
    dotProds = artistData{i}*u;
    minDist = min(dotProds);
    maxDist = max(dotProds);

    %Step 3: Create the distance matrix corresponding to this filtration
    DRows = repmat(dotProds, [1, length(dotProds)]);
    DCols = repmat(dotProds', [length(dotProds), 1]);
    D = max(DRows, DCols).*toKeep;%Don't add the edges until both points have been added
    %Also mask the edges by the graph that was extracted before
    %D = diag(dotProds);
    %D = squareform(pdist(artistData{i}));
    
    tda.RCA1( { 'settingsFile=data/cts.txt', 'supplyDataAs=distanceMatrix',sprintf('distanceBoundOnEdges=%g', 20)}, D );
    %I = get0DPersistence(D);
    I = tda.getResultsRCA1(0).getIntervals();
    subplot(2, 3, i);
    plot(I(:, 1), I(:, 2), '.');
    sum(isnan(I(:, 2)))
    minDist = min(min(I));
    maxDist = max(max(I));
    minDist = -1;
    
    xlim([minDist, maxDist]);
    ylim([minDist, maxDist]);
    hold on;
    plot([minDist, maxDist], [minDist, maxDist], 'r');
    axis square;
    title(sprintf('%s', artistNames{i}));
end

% if doMDS == 1
%     %Do multidimensional scaling
%     [Y,eigvals] = cmdscale(D);
%     gscatter(Y(:, 1), Y(:, 2), cell2mat(songInfoNums(:, 1)) );
%     genreNames = nominalValues(end-3, :);
%     genreNames = genreNames{1};
%     legend(genreNames);
% end

