load('GTzanFeaturesSlidingRips');
genres = {'blues', 'classical', 'country', 'disco', 'hiphop', 'jazz', 'metal', 'pop', 'reggae', 'rock'};
addpath('..');
addpath('../chroma-ansyn');
addpath('../rastamat');

%Which one do I want to plot?
genre = 'hiphop';
type = 'MFCC';
number = 0;


%Step 1: Compute the features
%This is assuming a texture window (so means/variances)
timbreIndices = [1:4 30:33 59];
MFCCIndices = [5:9 34:38];
ChromaIndices = [18:29 47:58];
hopSize = 512;
NWin = 43;
filename = sprintf('genres/%s/%s.%.5i.au', genre, genre, number);
DelaySeries = getDelaySeriesFeatures(filename, hopSize, 1, 10);
ScaleMeans = mean(DelaySeries, 1);
ScaleSTDevs = std(DelaySeries);
DelaySeries = bsxfun(@minus, DelaySeries, ScaleMeans);
DelaySeries = bsxfun(@times, DelaySeries, 1./ScaleSTDevs);
[~, YTimbre] = pca(DelaySeries(:, timbreIndices));
[~, YChroma] = pca(DelaySeries(:, ChromaIndices));
[~, YMFCC] = pca(DelaySeries(:, MFCCIndices));
idx = 1:NWin:size(DelaySeries, 1)-NWin-1;

%Step 2: Grab the precomputed diagrams
genresMap = java.util.HashMap();%Genre Name: index
for ii = 1:length(genres)
    genresMap.put(genres{ii}, ii);
end
index = genresMap.get(genre);

DGMs1MFCC = allDGMs1MFCC{index}{number+1};
DGMs1Chroma = allDGMs1Chroma{index}{number+1};
DGMs1Timbre = allDGMs1Timbre{index}{number+1};

if strcmp(type, 'MFCC')
    DGMs1 = DGMs1MFCC;
    Y = YMFCC;
elseif strcmp(type, 'Chroma')
    DGMs1 = DGMs1Chroma;
    Y = YChroma;
else
    DGMs1 = DGMs1Timbre;
    Y = YTimbre;
end

%Put them all on the same scale for plotting
AllIs = cell2mat(DGMs1);
minI = min(AllIs(:));
maxI = max(AllIs(:));

index = 1;
for ii = 1:length(DGMs1)
    clf;
    subplot(1, 2, 1);
    I = DGMs1{ii};
    if ~isempty(I)
        plot(I(:, 1), I(:, 2), '.');
    end
    hold on;
    plot([minI maxI], [minI maxI], 'r');
    xlim([minI, maxI]);
    ylim([minI, maxI]);
    subplot(1, 2, 2);
    plot(Y(:, 1), Y(:, 2), 'y');
    hold on;
    thisY = Y(idx(ii):idx(ii)+NWin-1, :);
    plot(thisY(:, 1), thisY(:, 2), 'c');
    for kk = 1:NWin
        thisY = Y(idx(ii):idx(ii)+kk-1, :);
        plot(thisY(:, 1), thisY(:, 2), 'k');
        plot(thisY(:, 1), thisY(:, 2), 'r.');
        xlim([min(Y(:)), max(Y(:))]);
        ylim([min(Y(:)), max(Y(:))]);
        print('-dpng', '-r100', sprintf('syncmovie%i.png', index));
        index = index + 1;
    end
end

FramesPerSecond = 22100.0/hopSize;
system(sprintf('avconv -r %g -i syncmovie%s.png -i genres/%s/%s.%.5d.au -b 65536k -r 24 %s%i_%s.ogg', ...
    FramesPerSecond, '%d', genre, genre, number, genre, number, type));
system('rm syncmovie*.png');

lengths = [];
for ii = 1:10
    for jj = 1:100
        for kk = 1:length(allDGMs1Timbre{ii}{jj});
            lengths = [lengths size(allDGMs1Timbre{ii}{jj}{kk}, 1)];
        end
    end
end
hist(lengths);
xlabel('Number of persistence points');
ylabel('Count');
title('Chroma Short DGM1 Number of Persistence Points Distribution');