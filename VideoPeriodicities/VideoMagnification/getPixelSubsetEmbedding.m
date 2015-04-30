%Purpose: To do an embedding of a series of patches in a video to turn
%then into a curve in high dimensions, and to use circular coordinates
%to describe where things are in the curve

%filename: Name of the video
%PatchRegions: An cell array of regions to examine.  Each cell i contains
%N regions of size k_i to examine, for each of N frames (allowing motion
%for each region in time)
%DelayWindow: How many frames to stack for each point
%SphereCenter: Whether or not to point-center and sphere normalize
function [region, R, theta] = getPixelSubsetEmbedding( filename, ...
    PatchRegions, DelayWindow, SphereCenter, DOAVERAGE, DOPLOT, FlipY )

    if nargin < 4
        SphereCenter = 0;
    end
    if nargin < 5
        DOAVERAGE = 1;
    end
    if nargin < 6
        DOPLOT = 0;
    end
    if nargin < 7;
        FlipY = 0;
    end
    obj = VideoReader(filename);
    N = obj.NumberOfFrames;
    fprintf(1, '%i frames in %s\n', N, filename);
    NRegions = length(PatchRegions);
    if DOAVERAGE
        region = zeros(N, 3*NRegions);
    else
        regionDims = cellfun(@(x) size(x, 2), PatchRegions);
        region = zeros(N, 3*prod(regionDims));
    end
    for ii = 1:N
        ii
        thisFrame = single(read(obj, ii));
        if FlipY
            for kk = 1:3
                thisFrame(:, :, kk) = flipud(thisFrame(:, :, kk));
            end
        end
        dims = size(thisFrame);
        thisFrame = reshape(thisFrame, [dims(1)*dims(2), dims(3)]);
        r = [];
        for kk = 1:NRegions
            thisr = thisFrame(PatchRegions{kk}(ii, :), :);
            if DOAVERAGE
                thisr = mean(thisr, 1);
            end
            r = [r; thisr(:)];
        end
        region(ii, :) = r(:)';
    end
    R = getSmoothedDerivative(region, DelayWindow);
    R = getDelayEmbedding(R, DelayWindow);
    if SphereCenter
        R = bsxfun(@minus, mean(R, 1), R);
        R = bsxfun(@times, 1./sqrt(sum(R.^2, 2)), R);
    end
    [~, Y] = pca(R);
    obj = VideoReader(filename);
    D = squareform(pdist(Y));
    
    %Dumb circular coordinates using atan2 on the first 2 principal
    %components
    theta = atan2(Y(:, 2), Y(:, 1));
    theta(theta > pi) = -theta(theta > pi);
    theta = mod(theta, 2*pi);
    theta = 255*theta/(2*pi);
    pcs = 1:2;
    
    if DOPLOT == 0
        return;
    end
    for ii = 1:size(Y, 1)
        clf;
        subplot(2, 2, 1);
        thisFrame = read(obj, ii);
        %Draw a box around the region of interest whose red channel
        %pulses with the circular coordinates
        dims = size(thisFrame);
        thisFrame = reshape(thisFrame, [dims(1)*dims(2), dims(3)]);
        if FlipY
            for kk = 1:3
                thisFrame(:, :, kk) = flipud(thisFrame(:, :, kk));
            end
        end
        for kk = 1:NRegions
            thisFrame(PatchRegions{kk}(ii, :), 1) = theta(ii);
        end
        thisFrame = reshape(thisFrame, dims);
        imagesc(thisFrame);
        axis off;
        
        subplot(2, 2, 2);
        imagesc(D);
        hold on;
        plot([0, size(Y, 1)], [ii, ii], 'r');
        axis off;
        
        subplot(2, 2, 3:4);
        plot(Y(:, 1), Y(:, 2), 'b');
        hold on;
        plot(Y(1:ii, 1), Y(1:ii, 2), 'r');
        scatter(Y(ii, 1), Y(ii, 2), 100, 'k', 'fill');
        title(sprintf('Principal Components %i - %i', pcs(1), pcs(end)));
        axis off;
        print('-dpng', '-r100', sprintf('%i.png', ii));
    end
end

