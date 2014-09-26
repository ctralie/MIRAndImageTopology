addpath('genres');
addpath('..');
addpath('../chroma-ansyn');
addpath('../rastamat');
addpath('../../0DFiltrations');
genres = {'blues', 'classical', 'country', 'disco', 'hiphop', 'jazz', 'metal', 'pop', 'reggae', 'rock'};
hopSize = 512;
NWin = 43;
SongsPerGenre = 100;

%This is assuming a texture window (so means/variances)
timbreIndices = [1:4 30:33 59];
MFCCIndices = [5:9 34:38];
ChromaIndices = [18:29 47:58];
allIndices = [timbreIndices MFCCIndices ChromaIndices];

morseDiagrams = cell(length(genres), 1);

for ii = 1:length(genres)
   genre = genres{ii};
   fprintf(1, 'Doing %s...\n', genre);
   PDs = cell(SongsPerGenre, 3);
   parfor jj = 1:SongsPerGenre
       filename = sprintf('genres/%s/%s.%.5i.au', genre, genre, jj-1);
       DelaySeries = getDelaySeriesFeatures(filename, hopSize, 1, NWin);
       Timbre = DelaySeries(:, timbreIndices);
       MFCC = DelaySeries(:, MFCCIndices);
       Chroma = DelaySeries(:, ChromaIndices);
       PDs{jj}{1} = getMorseFiltered0DDiagrams(Timbre);
       PDs{jj}{2} = getMorseFiltered0DDiagrams(MFCC);
       PDs{jj}{3} = getMorseFiltered0DDiagrams(Chroma);
       fprintf(1, '==========  Finished %s %i  ==========\n', genre, jj);
   end
   morseDiagrams{ii} = PDs;
end

save('GTzanMorseDiagrams.mat', 'morseDiagrams');
