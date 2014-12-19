addpath(genpath('src'));
files = textread('covers32k/allfiles.list', '%s\n');

for ii = 1:length(files);
    files{ii}
    %system(sprintf('avconv -i ../DelaySeries/artist20/mp3s-32k/%s.mp3 BeatsAndOggs/%i.ogg', files{ii}, ii));
    [X, Fs] = audioread(sprintf('covers32k/%s.mp3', files{ii}));
    audiowrite(sprintf('BeatsAndOggs/%s.ogg', files{ii}), X, Fs);
    
    [~, bts] = chrombeatftrs(X, Fs);
    meanMicroBeat = mean(bts(2:end) - bts(1:end-1));
    save(sprintf('BeatsAndOggs/%s.mat', files{ii}), 'bts', 'meanMicroBeat');
end
