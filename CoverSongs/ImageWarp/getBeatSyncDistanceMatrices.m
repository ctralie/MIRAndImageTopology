%This function exploits the overlapping nature of the beat sliding windows
%However, I can't normalize per window so I have to do one normalization
%up front.  This may lead to different results
function [ D ] = getBeatSyncDistanceMatrices( sprefix, dim, BeatsPerWin )
    addpath('../../');
    song = load(['../covers80/TempoEmbeddings/', sprefix, '.mat']);

    N = length(song.bts)-BeatsPerWin;
    if (N < 1)
        D = 0;
        return;
    end
    D = zeros(N, dim*dim);
    
    %Point-center and unit-normalize MFCCs
    Y = song.MFCC;
    Y = bsxfun(@minus, mean(Y), Y);
    Norm = 1./(sqrt(sum(Y.*Y, 2)));
    Y = Y.*(repmat(Norm, [1 size(Y, 2)]));
    
    Is = zeros(1, length(song.bts));
    for ii = 1:length(song.bts)
        Is(ii) = find(song.SampleDelaysMFCC > song.bts(ii), 1);
    end
    
    lastD = squareform(pdist(Y(Is(1):Is(1+BeatsPerWin), :)));
    lastDResiz = imresize(lastD, [dim dim]);
    D(1, :) = lastDResiz(:);
    
    for ii = 2:N
        i1 = Is(ii-1);
        i2 = Is(ii-1+BeatsPerWin);
        j1 = Is(ii);
        j2 = Is(ii+BeatsPerWin);
        
        %Reuse parts of distance matrix computed last time
        lastD = lastD((j1-i1)+1:end, (j1-i1)+1:end);
        YLast = Y(j1:i2, :);
        YNext = Y(i2+1:j2, :);
        DCorner = squareform(pdist(YNext));
        DSides = pdist2(YLast, YNext);
        
        thisD = [lastD DSides; DSides' DCorner];  
        thisDResiz = imresize(thisD, [dim dim]);
        D(ii, :) = thisDResiz(:);
        lastD = thisD;
    end
end