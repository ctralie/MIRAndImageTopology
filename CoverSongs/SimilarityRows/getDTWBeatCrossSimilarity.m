function [ D ] = getDTWBeatCrossSimilarity( s1prefix, s2prefix, BeatsPerWin, beatDownsample )
    addpath('../SequenceAlignment');
    if nargin < 4
        beatDownsample = 1;
    end
    song1 = load(['../covers80/TempoEmbeddings/', s1prefix, '.mat']);
    song2 = load(['../covers80/TempoEmbeddings/', s2prefix, '.mat']);
    
    SubsampleFac = 4;
    
	song1.bts = song1.bts(1:beatDownsample:end);
    song2.bts = song2.bts(1:beatDownsample:end);
    %Downsample to make faster
    song1.MFCC = song1.MFCC(1:SubsampleFac:end, :);
    song1.SampleDelaysMFCC = song1.SampleDelaysMFCC(1:SubsampleFac:end);
    song2.MFCC = song1.MFCC(1:SubsampleFac:end, :);
    song2.SampleDelaysMFCC = song2.SampleDelaysMFCC(1:SubsampleFac:end);    
    N = length(song1.bts)-BeatsPerWin;
    M = length(song2.bts)-BeatsPerWin;
    N = 50;
    M = 50;
    
    D = zeros(N, M);
    Delta = 200*BeatsPerWin/SubsampleFac;
    disp('Doing row embedding on song 1...');
    X1 = getNeighbDissimilarityRowsNoScale(song1.MFCC, Delta);
    X1 = bsxfun(@times, 1./sqrt(sum(X1.*X1, 2)), X1);
    disp('Doing row embedding on song 2...');
    X2 = getNeighbDissimilarityRowsNoScale(song2.MFCC, Delta);
    X2 = bsxfun(@times, 1./sqrt(sum(X2.*X2, 2)), X2);
    
    for ii = 1:N
        fprintf(1, '%i of %i\n', ii, N);
        tic
        i1 = find(song1.SampleDelaysMFCC > song1.bts(ii), 1);
        i2 = find(song1.SampleDelaysMFCC >= song1.bts(ii+BeatsPerWin), 1);
        X = X1(i1:i2, :);
        parfor jj = 1:M
            i1 = find(song2.SampleDelaysMFCC > song2.bts(jj), 1);
            i2 = find(song2.SampleDelaysMFCC >= song2.bts(jj+BeatsPerWin), 1);
            Y = X2(i1:i2, :);
            D(ii, jj) = getDTWDist(pdist2(X, Y));
            fprintf(1, '.');
        end
        toc;
    end
end