addpath(genpath('src'));
files = textread('covers32k/newlist.list', '%s\n');

for ii = 14:length(files);
    files{ii}
    %system(sprintf('avconv -i ../DelaySeries/artist20/mp3s-32k/%s.mp3 BeatsAndOggs/%i.ogg', files{ii}, ii));
    [X, Fs] = audioread(sprintf('covers32k/%s.mp3', files{ii}));
    X = mean(X, 2);
    audiowrite(sprintf('BeatsAndOggs/%s.ogg', files{ii}), X, Fs);
    
    [~, bts] = chrombeatftrs(X, Fs);
    bts = bts(1:2:end);%Take every half beat
    meanMicroBeat = mean(bts(2:end) - bts(1:end-1));
    save(sprintf('BeatsAndOggs/%s.mat', files{ii}), 'bts', 'meanMicroBeat');
    makeBeatsAudio(files{ii}, bts);
end
