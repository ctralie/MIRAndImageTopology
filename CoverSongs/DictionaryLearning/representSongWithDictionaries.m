%Trains a curve dissimilarity dictionary with "K" elements, resampling each
%image to be dim x dim pixels
function [alphas, fits] = representSongWithDictionaries(sprefix, Dicts, dim, BeatsPerWin, beatDownsample, lambda)
    addpath('../ImageWarp');
    if (nargin < 4)
        BeatsPerWin = 1;
    end
    if (nargin < 5)
        beatDownsample = 1;
    end
    if (nargin < 6)
        lambda = 0.15;%Sparsity vs fit tradeoff
    end
    
    addpath(genpath('spams-matlab'));

    %Point center and sphere-normalize point clouds
    X = getBeatSyncDistanceMatricesSlow(sprefix, dim, BeatsPerWin, beatDownsample);
    X = X';

    param.numThreads = 4;
    param.lambda = lambda;
    param.iter = 1000;
    param.mode = 2;
    param.posAlpha = 1;
    param.posD = 1;
    param.pos = 1;
    
    disp('Getting dictionary coefficients...');
    alphas = cell(length(Dicts), 1);
    fits = zeros(length(Dicts), 1);
    for ii = 1:length(Dicts)
        param.K = size(Dicts{ii}, 2);
        tic
        alphas{ii} = mexLasso(X, Dicts{ii}, param);
        toc
        fits(ii) = mean(0.5*sum((X-Dicts{ii}*alphas{ii}).^2));
        fprintf(1, '%i of %i fit %g\n', ii, length(Dicts), fits(ii));
    end
    disp('Finished getting dictionary coefficients');
end
