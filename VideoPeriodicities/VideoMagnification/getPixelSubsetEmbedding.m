%Purpose: To do an embedding of a series of patches in a video to turn
%then into a curve in high dimensions, and to use circular coordinates
%to describe where things are in the curve

%filename: Name of the video
%patchIDX: An N x k array of k pixel indices to examine each frame
%DelayWindow: How many frames to stack for each point
%SphereCenter: Whether or not to point-center and sphere normalize
function [region, R, theta] = getPixelSubsetEmbedding( filename, ...
    patchIDX, DelayWindow, SphereCenter, DOPLOT )

    if nargin < 4
        SphereCenter = 0;
    end
    if nargin < 5
        DOPLOT = 0;
    end
    obj = VideoReader(filename);
    N = obj.NumberOfFrames;
    fprintf(1, '%i frames in %s\n', N, filename);
    region = zeros(N, 3*size(patchIDX, 2));
    for ii = 1:N
        ii
        thisFrame = single(read(obj, ii));
        dims = size(thisFrame);
        thisFrame = reshape(thisFrame, [dims(1)*dims(2), dims(3)]);
        r = thisFrame(patchIDX(ii, :), :);
        %r = mean(r, 1);
        region(ii, :) = r(:)';
    end
    R = getSmoothedDerivative(region);
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
        thisFrame(patchIDX(ii, :), 1) = theta(ii);
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

