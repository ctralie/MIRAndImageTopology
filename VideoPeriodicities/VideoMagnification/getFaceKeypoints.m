function [Keypoints] = getFaceKeypoints( filename, FlipY, DOPLOT )
    if nargin < 2
        FlipY = 0;
    end
    if nargin < 3
        DOPLOT = 0;
    end
    disp('Initializing tracker...');
    [DM,TM,option] = xx_initialize;

    obj = VideoReader(filename);
    N = obj.NumberOfFrames
    
    thisFrame = read(obj, 1);
    if FlipY
        for ii = 1:3
            thisFrame(:, :, ii) = flipud(thisFrame(:, :, ii));
        end
    end
    size(thisFrame)
    output.pred = [];%prediction set to null enabling detection
    output = xx_track_detect(DM,TM,thisFrame,output.pred,option);
    Keypoints = zeros(N, size(output.pred, 1), 2);
    Keypoints(1, :, :) = output.pred;
    
    numsTxt = arrayfun(@(x) {sprintf('%i', x)}, 1:size(output.pred, 1));
    
    for n = 2:N
        n
        thisFrame = read(obj, n);
        if FlipY
            for ii = 1:3
                thisFrame(:, :, ii) = flipud(thisFrame(:, :, ii));
            end
        end
        output = xx_track_detect(DM,TM,thisFrame,output.pred,option);
        Keypoints(n, :, :) = output.pred;
        if DOPLOT
            clf;
            imagesc(thisFrame);
            X = output.pred;
            hold on;
            plot(X(:, 1), X(:, 2), 'g.');
            X = double(X);
            text(X(:, 1), X(:, 2), numsTxt);
            print('-dpng', '-r100', sprintf('%i.png', n));
        end
    end
    
end

