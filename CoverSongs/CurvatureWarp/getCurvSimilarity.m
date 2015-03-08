function [D] = getCurvSimilarity( file1, file2, BeatsPerWin )
    SamplesPerBeat = 200;
    Delta = 5;
    song1 = load(file1);
    song2 = load(file2);
    Curv1 = getSongApproxCurvature(song1.MFCC, Delta);
    Curv2 = getSongApproxCurvature(song2.MFCC, Delta);
    
	song1.bts = song1.bts(1:2:end);
	song2.bts = song2.bts(1:2:end);
	
    N = length(song1.bts)-BeatsPerWin;
    M = length(song2.bts)-BeatsPerWin;
    beats1 = zeros(N, BeatsPerWin*SamplesPerBeat);
    beats2 = zeros(M, BeatsPerWin*SamplesPerBeat);
    for ii = 1:N
        i1 = find(song1.SampleDelaysMFCC > song1.bts(ii), 1);
        i2 = find(song1.SampleDelaysMFCC >= song1.bts(ii+BeatsPerWin), 1);
        i1 = min(i1, length(Curv1));
        i2 = min(i2, length(Curv1));
        c = Curv1(i1:i2);
        if isempty(c)
            continue;
        end
        beats1(ii, :) = imresize(c, [SamplesPerBeat*BeatsPerWin, 1]);
    end
    
    for ii = 1:M
        i1 = find(song2.SampleDelaysMFCC > song2.bts(ii));
        i2 = find(song2.SampleDelaysMFCC >= song2.bts(ii+BeatsPerWin));
        i1 = min(i1, length(Curv2));
        i2 = min(i2, length(Curv2));
        c = Curv2(i1:i2);
        if isempty(c)
            continue;
        end
        beats2(ii, :) = imresize(c, [SamplesPerBeat*BeatsPerWin, 1]);
    end
    
    D = pdist2(beats1, beats2);
end