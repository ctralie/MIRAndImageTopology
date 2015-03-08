function [ D ] = getBeatSyncDistanceMatricesSlow( sprefix, dim, BeatsPerWin )
    addpath('../../');
    song = load(['../covers80/TempoEmbeddings/', sprefix, '.mat']);

    N = length(song.bts)-BeatsPerWin;
    
    D = zeros(N, dim*dim);
    
    %Point center and sphere-normalize point clouds
    for ii = 1:N
        i1 = find(song.SampleDelaysMFCC > song.bts(ii));
        i2 = find(song.SampleDelaysMFCC >= song.bts(ii+BeatsPerWin));
        Y = song.MFCC(i1:i2, :);
        if (isempty(Y))
            continue;
        end
        Y = bsxfun(@minus, mean(Y), Y);
%         Y = bsxfun(@times, std(Y), Y);
        Norm = 1./(sqrt(sum(Y.*Y, 2)));
        Y = Y.*(repmat(Norm, [1 size(Y, 2)]));
        thisD = squareform(pdist(Y));
        thisD = imresize(thisD, [dim dim]);
        D(ii, :) = thisD(:);
    end
end