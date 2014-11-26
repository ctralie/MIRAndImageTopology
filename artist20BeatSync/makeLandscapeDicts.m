addpath(genpath('spams-matlab'));
start_spams;
addpath('..');


%Parameters
LandscapeRes = 100;
xrangeLandscape = linspace(0, 2, LandscapeRes);
yrangeLandscape = linspace(0, 0.6, LandscapeRes);
NArtists = 20;
NDictElems = 32;
param.K = NDictElems;
param.numThreads = 4;
param.lambda = 0.15;
param.iter = 1000;

files = textread('a20-all-tracks.txt', '%s\n');
artistsMap = java.util.TreeMap();
songsByArtist = cell(1, NArtists);
songsMap = java.util.TreeMap();

%Create an ID map for the songs
for ii = 1:length(files)
    f = strsplit(files{ii}, '/');
    if isempty(artistsMap.get(f{1}))
        artistsMap.put(f{1}, artistsMap.size() + 1);
        idx = artistsMap.size() + 1;
        songsByArtist{idx} = {};
    end
    songsMap.put(files{ii}, ii);
end

%Now train dictionaries on the training set only per artist
files = textread('a20-trn-tracks.list', '%s\n');
for ii = 1:length(files)
    f = strsplit(files{ii}, '/');
    idx = artistsMap.get(f{1});
    songsByArtist{idx}{end+1} = files{ii};
end

LandscapeDs = cell(1, NArtists);

for ii = 1:20
    NSongs = length(songsByArtist{ii});
    f = strsplit(songsByArtist{ii}{1}, '/');
    X = [];
    fprintf(1, 'Calculating persistence landscape dictionary for %s\n', f{1});
    for kk = 1:NSongs
        fprintf(1, '%i of %i songs for %s\n', kk, NSongs, f{1});
        idx = songsMap.get(songsByArtist{ii}{kk});
        Feats = load(sprintf('BeatSyncFeatures/BeatSync%i.mat', idx));
        thisX = zeros(LandscapeRes*LandscapeRes, length(Feats.Is));
        %Go through every persistence diagram and add to the dictionary
        for jj = 1:length(Feats.Is)
            L = getRasterizedLandscape(Feats.Is{jj}, xrangeLandscape, yrangeLandscape, 10);
            thisX(:, jj) = L(:);
        end
        X = [X thisX];
    end
    fprintf(1, 'Training landscape dictionary for %s\n', f{1});
    LandscapeDs{ii} = nnsc(X, param);
    fprintf(1, 'Finished training landscape dictionary for %s\n\n', f{1});
end