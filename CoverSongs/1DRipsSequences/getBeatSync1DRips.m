function [ DGMs ] = getBeatSync1DRips( sprefix, BeatsPerWin, beatDownsample, tda )
    addpath('../../');
    if nargin < 3
        beatDownsample = 1;
    end
    if nargin < 4
        javaclasspath('jars/tda.jar');
        import api.*;
        tda = Tda();
    end
    song = load(['../covers80/TempoEmbeddings/', sprefix, '.mat']);

	song.bts = song.bts(1:beatDownsample:end);
    N = length(song.bts)-BeatsPerWin;
    
    DGMs = cell(N, BeatsPerWin);
    
    %Point center and sphere-normalize point clouds
    for ii = 1:N
        i1 = find(song.SampleDelaysMFCC > song.bts(ii));
        i2 = find(song.SampleDelaysMFCC >= song.bts(ii+BeatsPerWin));
        Y = song.MFCC(i1:i2, :);
        if (isempty(Y))
            continue;
        end
        Y = bsxfun(@minus, mean(Y), Y);
        Norm = 1./(sqrt(sum(Y.*Y, 2)));
        Y = Y.*(repmat(Norm, [1 size(Y, 2)]));
        
        for kk = 1:BeatsPerWin
            thisi1 = find(song.SampleDelaysMFCC(i1:end) > song.bts(ii+kk-1), 1);
            thisi2 = find(song.SampleDelaysMFCC(i1:end) >= song.bts(ii+kk), 1);
            %Downsample the points for speed if taking larger beat
            %intervals
            DSub = squareform(pdist(Y(thisi1:beatDownsample:thisi2, :)));
            tda.RCA1( { 'settingsFile=data/cts.txt', 'supplyDataAs=distanceMatrix', ...
               sprintf('distanceBoundOnEdges=%g', max(DSub(:)) + 10)}, DSub );
            I = tda.getResultsRCA1(1).getIntervals();
            DGMs{ii, kk} = I;
        end
    end
end