function [D, beats1, beats2] = getCurvSimilarity1DMorse( file1, file2, BeatsPerWin, NBars )
    init;
    Delta = 5;
    song1 = load(file1);
    song2 = load(file2);
    Curv1 = getSongApproxCurvature(song1.MFCC, Delta);
    Curv2 = getSongApproxCurvature(song2.MFCC, Delta);
    
    N = length(song1.bts)-BeatsPerWin;
    M = length(song2.bts)-BeatsPerWin;
    beats1 = zeros(N, NBars);
    beats2 = zeros(N, NBars);
    for ii = 1:N
        i1 = find(song1.SampleDelaysMFCC > song1.bts(ii));
        i2 = find(song1.SampleDelaysMFCC >= song1.bts(ii+BeatsPerWin));
        I = morseFiltration(Curv1(i1:i2));
        if ~isempty(I)
            I = sort(I(:, 2) - I(:, 1), 'descend');
            nnonzero = min(size(I, 1), NBars);
            beats1(ii, 1:nnonzero) = I(1:nnonzero);
        end
    end
    
    for ii = 1:M
        i1 = find(song2.SampleDelaysMFCC > song2.bts(ii));
        i2 = find(song2.SampleDelaysMFCC >= song2.bts(ii+BeatsPerWin));
        I = morseFiltration(Curv2(i1:i2));
        if ~isempty(I)
            I = sort(I(:, 2) - I(:, 1), 'descend');
            nnonzero = min(size(I, 1), NBars);
            beats2(ii, 1:nnonzero) = I(1:nnonzero);
        end
    end
    
    D = pdist2(beats1, beats2);
end