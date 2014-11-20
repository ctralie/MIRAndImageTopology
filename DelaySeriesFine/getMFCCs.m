alltracks = 'a20-all-tracks.txt';
files = textread(alltracks, '%s\n');

for ii = 1:length(files);
    [X, Fs] = audioread(sprintf('../DelaySeries/artist20/mp3s-32k/%s.mp3', files{ii}));
    ChromaFtrs = load( sprintf('../DelaySeries/artist20/chromftrs/%s.mat', files{ii}) );
    
    bts = ChromaFtrs.bts;
    meanMicroBeat = mean(bts(2:end) - bts(1:end-1));
    
    tic;
    [DelaySeries, SampleDelays] = localTDABeats(X, Fs, meanMicroBeat);
    toc;
    
    save(sprintf('BeatSyncMFCCs/%i.mat', ii), 'DelaySeries', 'SampleDelays', 'bts', 'meanMicroBeat');
end