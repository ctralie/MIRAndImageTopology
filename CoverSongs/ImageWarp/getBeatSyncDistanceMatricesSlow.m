function [ D, beatIdx ] = getBeatSyncDistanceMatricesSlow( sprefix, dim, BeatsPerWin, beatDownsample )
    addpath('../../');
    if nargin < 4
        beatDownsample = 1;
    end
    song = load(['../covers80/TempoEmbeddings/', sprefix, '.mat']);

	song.bts = song.bts(1:beatDownsample:end);    
    N = length(song.bts)-BeatsPerWin;
    
    D = zeros(N, dim*dim);
    
    beatIdx = zeros(1, length(song.bts));
    idx = 1;
    for ii = 1:N
        while(song.SampleDelaysMFCC(idx) < song.bts(ii))
            idx = idx + 1;
        end
        beatIdx(ii) = idx;
    end
    
    %Point center and sphere-normalize point clouds
    parfor ii = 1:N
        Y = song.MFCC(beatIdx(ii)+1:beatIdx(ii+BeatsPerWin), :);
        if (isempty(Y))
            continue;
        end
        Y = bsxfun(@minus, mean(Y), Y);
%         Y = bsxfun(@times, std(Y), Y);
        Norm = 1./(sqrt(sum(Y.*Y, 2)));
        Y = Y.*(repmat(Norm, [1 size(Y, 2)]));
        dotY = dot(Y, Y, 2);
        thisD = bsxfun(@plus, dotY, dotY') - 2*(Y*Y');
        thisD = imresize(thisD, [dim dim]);
        D(ii, :) = thisD(:);
    end
end