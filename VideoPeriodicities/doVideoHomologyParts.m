addpath('../TDAMex');
load('DMatrices/DBeatingHeart_HOG3D.mat');
N = size(D, 1);
M = 40;

SAVESLIDINGPERSISTENCEVIDEO = 0;

if ~exist('BeatingHeartParts.mat')
    offsets = 1:N-M-1;
    persistences = zeros(1, length(offsets));
    maxGenerators = cell(1, length(offsets));
    J = zeros(length(offsets), 2);
    for ii = offsets
        fprintf(1, '%i of %i\n', ii, length(offsets));
        DSub = D(ii:ii+40-1, ii:ii+40-1);
        minDist = min(DSub(:));
        maxDist = max(DSub(:));
        [I, thisJ, JGenerators] = getGeneratorsFromTDAJar(DSub, maxDist);
        if ~isempty(thisJ)
            [persistences(ii), idx] = max(thisJ(:, 2) - thisJ(:, 1));
            maxGenerators{ii} = JGenerators{idx} + (ii-1);
            J(ii, :) = thisJ(idx, :);
        end
    end
    save('BeatingHeartParts.mat', 'J', 'maxGenerators', 'offsets', 'persistences');
else
    load('BeatingHeartParts.mat');
end

videoReader = VideoReader('BeatingHeart.mp4');
frameIndex = 0;
vidWidth = videoReader.Width;
vidHeight = videoReader.Height;
%mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
%    'colormap',[]);

if SAVESLIDINGPERSISTENCEVIDEO
    Y = cmdscale(D);
    for ii = 1:length(offsets)
        clf;
        ii
        cdata = read(videoReader, ii+40);
        DSub = D(ii:ii+40-1, ii:ii+40-1);
        subplot(2, 2, 1);
        imagesc(cdata);
        axis off;
        subplot(2, 2, 2);
        scatter(Y(ii:ii+40-1, 1), Y(ii:ii+40-1, 2), 25, 'b', 'fill');

        subplot(2, 2, 3:4);
        plot(offsets, persistences);
        hold on;
        stem([offsets(ii), offsets(ii)], [0, persistences(ii)], 'r');
        xlabel('Starting Frame Number');
        ylabel('Max Persistence');
        %title('Max Persistence of 40 frame subsets of Beating Heart Video');
        print('-dpng', '-r100', sprintf('%i.png', ii));
        print('-dsvg', '-r100', sprintf('%i.svg', ii));
    end
end

%Get rid of duplicate persistence pairs
unique = ones(size(persistences));
lastGenerator = maxGenerators{1};
for ii = 2:length(unique)
    if length(lastGenerator) ~= length(maxGenerators{ii})
       unique(ii) = 0;
    elseif sum(sort(lastGenerator) == sort(maxGenerators{ii})) == length(lastGenerator)
       unique(ii) = 0;
    end
    lastGenerator = maxGenerators{ii};
end
fprintf(1, 'There are %i unique generators\n', sum(unique));
J = J(unique == 1, :);
maxGenerators = maxGenerators(unique == 1);


saveVideoGenerators( 'BeatingHeart.mp4', 'BeatingHeartPartial', J, maxGenerators, sum(unique), D);