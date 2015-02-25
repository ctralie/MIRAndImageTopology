%Trains a curve dissimilarity dictionary with "K" elements, resampling each
%image to be dim x dim pixels
function [alphas, fits] = representSongWithDictionaries(sprefix, Dicts, dim, BeatsPerWin)
    if (nargin < 4)
        BeatsPerWin = 1;
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

    param.K = size(D, 2);
    param.numThreads = 4;
    param.lambda = 0.15;
    param.iter = 1000;
    param.mode = 2;
    param.posAlpha = 1;
    param.posD = 1;
    param.pos = 1;
    
    disp('Getting dictionary coefficients...');
    alphas = cell(length(Dicts), 1);
    fits = zeros(length(Dicts), 1);
    for ii = 1:length(Dicts)
        alphas{ii} = mexLasso(X, Dicts{ii}, param);
        fits(ii) = mean(0.5*sum((X-Dicts{ii}*alphas{ii}).^2));
        fprintf(1, '%i of %i fit %g\n', ii, length(Dicts), fits(ii));
    end
    disp('Finished getting dictionary coefficients');
end