alltracks = 'a20-all-tracks.txt';
files = textread(alltracks, '%s\n');

for ii = 1:length(files);
    ii
    %system(sprintf('avconv -i ../DelaySeries/artist20/mp3s-32k/%s.mp3 BeatsAndOggs/%i.ogg', files{ii}, ii));
    [X, Fs] = audioread(sprintf('../DelaySeries/artist20/mp3s-32k/%s.mp3', files{ii}));
    audiowrite(sprintf('BeatsAndOggs/%i.ogg', ii), X, Fs);
    
    chromfilename = sprintf('../DelaySeries/artist20/chromftrs/%s.mat', files{ii})
    ChromaFtrs = load( chromfilename );
    bts = ChromaFtrs.bts;
    meanMicroBeat = mean(bts(2:end) - bts(1:end-1));
    save(sprintf('BeatsAndOggs/%i.mat', ii), 'bts', 'meanMicroBeat');
end