addpath('../../DelaySeries');
files = textread('allfiles.list', '%s\n');
for songIdx = 1:length(files)
    outname = sprintf('TempoEmbeddings/%s.mat', files{songIdx});
    if exist(outname)
        fprintf(1, 'Skipping %s\n', outname);
        continue;
    end
    fprintf(1, 'Doing %s...', files{songIdx});
    filename = sprintf('BeatsAndOggs/%s.ogg', files{songIdx});
    [X, Fs] = audioread(filename);
    beatsFilename = sprintf('BeatsAndOggs/%s.mat', files{songIdx});
    bts = load(beatsFilename);
    bts = bts.bts;
    tempoPeriod = mean(bts(2:end) - bts(1:end-1));
    [Chroma, SampleDelaysChroma] = getChromaTempoWindow(filename, tempoPeriod, 36);
    [MFCC, SampleDelaysMFCC] = getMFCCTempoWindow(filename, tempoPeriod);
    save(outname, 'Chroma', 'SampleDelaysChroma', 'MFCC', 'SampleDelaysMFCC', 'bts');
end