files = ls('song*.mat');
files = strsplit(files);
files = files(1:end-1);

songs = cell(1, length(files));
DGMs1Timbre = zeros(length(files), 200);
DGMs1MFCC = zeros(length(files), 200);
DGMs1Chroma = zeros(length(files), 200);

parfor ii = 1:length(files)
    %files{ii}
    song = load(files{ii});
    song = song.songsDiagram;
    songs{ii} = song;
    DGMs1Timbre(ii, :) = getSortedBars(song.I1Timbral, 1, 100);
    DGMs1MFCC(ii, :) = getSortedBars(song.I1MFCC, 1, 100);
    DGMs1Chroma(ii, :) = getSortedBars(song.I1Chroma, 1, 100);
end
DGMs1Timbre = MuStdCenter(DGMs1Timbre);
DGMs1MFCC = MuStdCenter(DGMs1MFCC);
DGMs1Chroma = MuStdCenter(DGMs1Chroma);

[TimbrePCs, TimbrePCA] = pca(DGMs1Timbre);
[MFCCPCs, MFCCPCA] = pca(DGMs1MFCC);
[ChromaPCs, ChromaPCA] = pca(DGMs1Chroma);

TimbrePCA = DGMs1Timbre*TimbrePCs;
MFCCPCA = DGMs1MFCC*MFCCPCs;
ChromaPCA = DGMs1Chroma*ChromaPCs;

TimbrePCA = MuStdCenter(TimbrePCA);
MFCCPCA = MuStdCenter(MFCCPCA);
ChromaPCA = MuStdCenter(ChromaPCA);

for ii = 1:length(songs)
   songs{ii}.principalComp200I1Timbre_Chris = TimbrePCA(ii, 1:5);
   songs{ii}.principalComp200I1MFCC_Chris = MFCCPCA(ii, 1:5);
   songs{ii}.principalComp200I1Chroma_Chris = ChromaPCA(ii, 1:5);
end