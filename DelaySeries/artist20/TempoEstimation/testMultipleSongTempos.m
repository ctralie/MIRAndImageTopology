alltracks = 'a20-all-tracks.txt';
files = textread(alltracks, '%s\n');
addpath('../../');
addpath('../../chroma-ansyn');
addpath('../../rastmat');

for ii = 2:100:1402
    estimateTempoTDA(files{ii}, ii);
end