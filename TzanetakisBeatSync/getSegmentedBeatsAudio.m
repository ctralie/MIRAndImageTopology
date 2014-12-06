function [] = getSegmentedBeatsAudio( index, k )
    c = {'r', 'g', 'b', 'c', 'm', 'y', 'k'};

    genres = {'blues', 'classical', 'country', 'disco', 'hiphop', 'jazz', 'metal', 'pop', 'reggae', 'rock'};
    D = load('D.mat');
    X = D.Alphas(:, D.idxranges{index});
    X = full(X)';
    
    genre = genres{floor(index/100) + 1};
    song = mod(index, 100) - 1;
    audiofile = sprintf('genres/%s/%s.%.5d.au', genre, genre, song)
    beatsfile = sprintf('genres/%s/%s.%.5d.mat', genre, genre, song);
    [xaudio, Fs] = audioread(audiofile);
    bts = load(beatsfile);
    
    idx = kmeans(X, k);
    
    [~, Y] = pca(X);
    hold on;
    for ii = 1:k
        y = Y(idx == ii, 1:2);
        plot(y(:, 1), y(:, 2), sprintf('%s*', c{ii}));
        %Extract audio chunks in this cluster
        xchunk = [];
        for kk = 1:length(idx)
            if idx(kk) == ii
                starti = round(bts.onsets(kk)*Fs);
                endi = round( (bts.onsets(kk+1) + bts.durations(kk+1) )*Fs );
                xchunk = [xchunk; xaudio(starti:endi); zeros(round(Fs/4), 1)];
            end
        end
        audiowrite(sprintf('%s.%.5d_%i.ogg', genre, song, ii), xchunk, Fs);
    end
end