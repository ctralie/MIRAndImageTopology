function [D] = getCurvSimilarity( file1, file2 )
    Delta = 5;
    song1 = load(file1);
    song2 = load(file2);
    Curv1 = getSongApproxCurvature(song1.MFCC, Delta);
    Curv2 = getSongApproxCurvature(song2.MFCC, Delta);
    
    N = length(song1.bts)-1;
    M = length(song2.bts)-1;
    beats1 = cell(1, N);
    beats2 = cell(1, M);
    for ii = 1:N
        i1 = find(song1.SampleDelaysMFCC > song1.bts(ii));
        i2 = find(song1.SampleDelaysMFCC >= song1.bts(ii+1));
        beats1{ii} = Curv1(i1:i2);
    end
    
    %lengths1 = cell2mat(cellfun(@(x) {length(x)}, beats1));
    %plot(lengths1);
    
    for ii = 1:M
        i1 = find(song2.SampleDelaysMFCC > song2.bts(ii));
        i2 = find(song2.SampleDelaysMFCC >= song2.bts(ii+1));
        beats2{ii} = Curv2(i1:i2);
    end
    
    D = zeros(N, M);
    for ii = 1:N
        x1 = beats1{ii};
        row = zeros(1, M);
        fprintf(1, '%i of %i\n', ii, N);
        parfor jj = 1:M
            x2 = beats2{jj};
            x2 = imresize(x2, [length(x1), 1]);
            row(jj) = sqrt(sum((x1 - x2).^2));
        end
        D(ii, :) = row;
    end
end