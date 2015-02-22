addpath('../../DelaySeries');
files = textread('allfiles.list', '%s\n');
for songIdx = 2:length(files)
    fprintf(1, 'Doing %s...', files{songIdx});
    filename = sprintf('BeatsAndOggs/%s.ogg', files{songIdx});
    [X, Fs] = audioread(filename);
    beatsFilename = sprintf('BeatsAndOggs/%s.mat', files{songIdx});
    bts = load(beatsFilename);
    bts = bts.bts;
    tempoPeriod = mean(bts(2:end) - bts(1:end-1));
    [Chroma, SampleDelaysChroma] = getChromaTempoWindow(filename, tempoPeriod);
    [MFCC, SampleDelaysMFCC] = getMFCCTempoWindow(filename, tempoPeriod);
    save(sprintf('TempoEmbeddings/%s.mat', files{songIdx}), 'Chroma', 'SampleDelaysChroma', 'MFCC', 'SampleDelaysMFCC', 'bts');
end