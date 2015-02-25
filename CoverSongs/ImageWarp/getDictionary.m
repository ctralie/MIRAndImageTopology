%Trains a curve dissimilarity dictionary with "K" elements, resampling each
%image to be dim x dim pixels
function [D] = getDictionary(sprefix, K, dim, BeatsPerWin, DOPLOT)
    if (nargin < 4)
        BeatsPerWin = 1;
    end
    if (nargin < 5)
        DOPLOT = 0;
    end
    
    addpath(genpath('spams-matlab'));
    addpath('../../');
    song = load(['../covers80/TempoEmbeddings/', sprefix, '.mat']);


    N = length(song.bts)-BeatsPerWin;

    X = zeros(dim*dim, N);

    %Point center and sphere-normalize point clouds
    for ii = 1:N
        i1 = find(song.SampleDelaysMFCC > song.bts(ii));
        i2 = find(song.SampleDelaysMFCC >= song.bts(ii+BeatsPerWin));
        if isempty(song.MFCC(i1:i2, :))
            continue;
        end
        D = getScaledDist(song.MFCC(i1:i2, :), 1);
        D = imresize(D, [dim, dim]);
        X(:, ii) = D(:);
    end

    param.K = K;
    param.numThreads = 4;
    param.lambda = 0.15;
    param.iter = 1000;

    disp('Training dictionary...');
    D = nnsc(X, param);
    disp('Finished training dictionary');

    if DOPLOT
        for ii = 1:8
            subplot(3, 3, ii);
            I = D(:, ii);
            imagesc(reshape(I, [dim, dim]));
        end
        figure;
        for ii = 1:8
            subplot(3, 3, ii);
            I = D(:, ii);
            I = reshape(I, [dim, dim]);
            I = 0.5*(I+I');
            I(1:size(I, 1)+1:end) = 0;
            [Y, lams] = cmdscale(I);
            plot3(Y(:, 1), Y(:, 2), Y(:, 3));
            lams = abs(lams);
            title(sprintf('%g', sum(lams(1:3))/sum(lams)));
        end
    end
end