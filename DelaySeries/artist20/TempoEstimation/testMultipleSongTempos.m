alltracks = '../lists/a20-all-tracks.list';
files = textread(alltracks, '%s\n');

for ii = 2:100:1402
    estimateTempoTDA(files{ii}, ii);
end