function [Keypoints] = getFaceKeypoints( getFrameFn, DOPLOT, NFrames )
    if nargin < 2
        DOPLOT = 0;
    end
    disp('Initializing tracker...');
    [DM,TM,option] = xx_initialize;

    if nargin < 3
        N = getFrameFn(-1);
    else
        N = NFrames;
    end
    
    thisFrame = getFrameFn(1);
    size(thisFrame)
    output.pred = [];%prediction set to null enabling detection
    output = xx_track_detect(DM,TM,thisFrame,output.pred,option);
    Keypoints = zeros(N, size(output.pred, 1), 2);
    Keypoints(1, :, :) = output.pred;
    
    numsTxt = arrayfun(@(x) {sprintf('%i', x)}, 1:size(output.pred, 1));
    
    for n = 2:N
        n
        thisFrame = getFrameFn(n);
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

