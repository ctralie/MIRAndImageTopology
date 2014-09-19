import java.util.HashMap;
featuresOrig = cell(1, 10);

%Take care of reggae 86
load('song877.mat');
songsDiagram.fileName = '/gtmp/Summer2014DataRTG/tzanetakisMusic/genres/reggae/reggae.00086.au';
save('song878.mat', 'songsDiagram');

for ii = 1:10
    featuresOrig{ii} = zeros(100, 59*2);
end
AllPDs0 = {};
AllPDs1 = {};
genres = {'blues', 'classical', 'country', 'disco', 'hiphop', 'jazz', 'metal', 'pop', 'reggae', 'rock'};
genresMap = HashMap();
for ii = 1:length(genres)
   genresMap.put(genres{ii}, ii); 
end

timbreIndices = [1:4 30:33 59];
MFCCIndices = [5:9 34:38];
ChromaIndices = [18:29 47:58];

for index = 1:1000
    song = load(sprintf('song%i.mat', index));
    song = song.songsDiagram;
    filename = song.fileName;
    [~, filename, ~] = fileparts(filename);
    parts = strsplit(filename, '.');
    ii = genresMap.get(parts{1});
    jj = str2double(parts{2}) + 1;
    fprintf(1, '%i: %s: %i, %i\n', index, filename, ii, jj);
    AllPDs0{ii}{jj}{1} = song.I0Timbral;
    AllPDs0{ii}{jj}{2} = song.I0MFCC;
    AllPDs0{ii}{jj}{3} = song.I0Chroma;
    AllPDs1{ii}{jj}{1} = song.I1Timbral;
    AllPDs1{ii}{jj}{2} = song.I1MFCC;
    AllPDs1{ii}{jj}{3} = song.I1Chroma;

    DelaySeries = zeros(size(song.Timbral, 1), 59);
    DelaySeries(:, [timbreIndices MFCCIndices ChromaIndices]) = [song.Timbral song.MFCC song.Chroma];
    featuresOrig{ii}(jj, :) = [mean(DelaySeries, 1) sqrt(var(DelaySeries, 1))];
end

save('GTzanFeatures.mat', 'featuresOrig', 'AllPDs0', 'AllPDs1', 'genres');
