NFiles = 64;
musicFiles = strsplit(ls('music_wav'));
musicFiles = musicFiles(1:NFiles);
speechFiles = strsplit(ls('speech_wav'));
speechFiles = speechFiles(1:NFiles);
files = cell(1, NFiles*2);
for ii = 1:NFiles
    files{ii} = sprintf('music_wav/%s', musicFiles{ii});
end
for ii = 1:NFiles
    files{NFiles+ii} = sprintf('speech_wav/%s', speechFiles{ii});
end

Kurts = zeros(1, length(files));
KurtsEnv = zeros(1, length(files));
parfor ii = 1:length(files)
    files{ii}
    [X, Fs] = audioread(files{ii});
    [M, env] = onsetenv(X, Fs);
    Y = get1DDelayEmbedding(env, 125, 1);
    
    D = bsxfun(@plus, sum(Y.^2, 2), sum(Y.^2, 2)') - 2*(Y*Y');
    D(D < 0) = 0;
    D = 0.5*(D+D');
    D(1:size(D, 1)+1:end) = 0;
    D = sqrt(D);
    
%     diagsum = zeros(1, size(D, 1));
%     for kk = 1:size(D, 1)
%         diagsum(kk) = sum(diag(D, kk-1));
%     end
%     diagsum = diagsum./(length(diagsum):-1:1);
    diagsum = zeros(1, size(D, 1));
    for kk = 1:size(D, 1)
        diagsum(kk) = sum(D(kk:size(D, 1)+1:end));
    end

    fftdiag = abs(fft(diagsum));
    fftdiag(1) = 0;
    fftdiag = fftdiag/max(fftdiag);
    Kurts(ii) = kurtosis(fftdiag);
    KurtsEnv(ii) = kurtosis(abs(fft(env)));
end

KurtsM = Kurts(1:NFiles);
KurtsS = Kurts(NFiles+1:end);
[~, idx] = sort(Kurts);
idx = idx > NFiles;
NMusic = sum(idx(1:NFiles))
NSpeech = sum(idx(NFiles+1:end))
(NFiles*2 - NSpeech*2)/(NFiles*2)