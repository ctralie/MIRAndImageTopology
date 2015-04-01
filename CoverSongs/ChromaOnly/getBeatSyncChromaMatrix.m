function [ ChromaAvg ] = getBeatSyncChromaMatrix( sprefix, BeatsPerWin, beatDownsample, rotate )
    addpath('../../');
    if nargin < 3
        beatDownsample = 1;
    end
    if nargin < 4
        rotate = 0;%How much to rotate the chroma matrices
    end
    song = load(['../covers80/TempoEmbeddings/', sprefix, '.mat']);
    if rotate > 0
        song.Chroma = circshift(song.Chroma, rotate, 2);
    end
    
	song.bts = song.bts(1:beatDownsample:end);    
    N = length(song.bts)-BeatsPerWin;
    
    ChromaAvg = zeros(N, size(song.Chroma, 2));
    
    %Point center and sphere-normalize point clouds
    parfor ii = 1:N
        i1 = find(song.SampleDelaysMFCC > song.bts(ii));
        i2 = find(song.SampleDelaysMFCC >= song.bts(ii+BeatsPerWin));
        Y = song.Chroma(i1:i2, :);
        if (isempty(Y))
            continue;
        end
        ChromaAvg(ii, :) = mean(Y, 1);
    end
    ChromaAvg = bsxfun(@times, 1./max(ChromaAvg, [], 1), ChromaAvg);
end

