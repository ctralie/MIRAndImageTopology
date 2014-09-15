%Programmer: Chris Tralie
%Purpose: To extract the CAF and persistence features from the George
%Tzanetakis 2002 speech/music
%indices: The indices of the genres to compute (Useful to run this file
%on different cores with different indices to parallelize computation)

addpath('genres');
addpath('..');
addpath('../chroma-ansyn');
addpath('../rastamat');
hopSize = 512;
NWin = 43;

%This is assuming a texture window (so means/variances)
timbreIndices = [1:4 30:33 59];
MFCCIndices = [5:9 34:38];
ChromaIndices = [18:29 47:58];

ScalingInfo = load('ScalingInfo');
ScaleMeans = ScalingInfo.means;
ScaleSTDevs = sqrt(ScalingInfo.vars);

NFiles = 64;
musicFiles = strsplit(ls('music_wav'));
musicFiles = musicFiles(1:NFiles);
speechFiles = strsplit(ls('speech_wav'));
speechFiles = speechFiles(1:NFiles);


disp('Doing Music...');
X = zeros(NFiles, 59*2);
PDs1 = cell(NFiles, 1);
PDs0 = cell(NFiles, 1);
parfor jj = 1:NFiles
   filename = sprintf('music_wav/%s', musicFiles{jj});
   DelaySeries = getDelaySeriesFeatures(filename, hopSize, 1, NWin);
   %Save the mean and variance of all features to "featuresOrig"
   thisX = [mean(DelaySeries, 1) sqrt(var(DelaySeries, 1))];
   X(jj, :) = thisX;
   %Now scale the delay series by the precomputed mean and standard
   %deviation
   DelaySeries = bsxfun(@minus, DelaySeries, ScaleMeans);
   DelaySeries = bsxfun(@times, DelaySeries, 1./ScaleSTDevs);
   %Do DGM1 separately for timbre, MFCC, and chroma
   %Subsample the point clouds by a factor of 2
   [timbrePD1, timbrePD0] = getPersistenceDiagrams(DelaySeries(:, timbreIndices));
   [MFCCPD1, MFCCPD0] = getPersistenceDiagrams(DelaySeries(:, MFCCIndices));
   [ChromaPD1, ChromaPD0] = getPersistenceDiagrams(DelaySeries(:, ChromaIndices));
   PDs1{jj} = {timbrePD1, MFCCPD1, ChromaPD1};
   PDs0{jj} = {timbrePD0, MFCCPD0, ChromaPD0};
   fprintf(1, 'Finished music %i\n', jj);
end
save('MusicFeatures.mat', 'X', 'PDs1', 'PDs0');



disp('Doing Speech...');
X = zeros(NFiles, 59*2);
PDs1 = cell(NFiles, 1);
PDs0 = cell(NFiles, 1);
parfor jj = 1:NFiles
   filename = sprintf('speech_wav/%s', speechFiles{jj});
   DelaySeries = getDelaySeriesFeatures(filename, hopSize, 1, NWin);
   %Save the mean and variance of all features to "featuresOrig"
   thisX = [mean(DelaySeries, 1) sqrt(var(DelaySeries, 1))];
   X(jj, :) = thisX;
   %Now scale the delay series by the precomputed mean and standard
   %deviation
   DelaySeries = bsxfun(@minus, DelaySeries, ScaleMeans);
   DelaySeries = bsxfun(@times, DelaySeries, 1./ScaleSTDevs);
   %Do DGM1 separately for timbre, MFCC, and chroma
   %Subsample the point clouds by a factor of 2
   [timbrePD1, timbrePD0] = getPersistenceDiagrams(DelaySeries(:, timbreIndices));
   [MFCCPD1, MFCCPD0] = getPersistenceDiagrams(DelaySeries(:, MFCCIndices));
   [ChromaPD1, ChromaPD0] = getPersistenceDiagrams(DelaySeries(:, ChromaIndices));
   PDs1{jj} = {timbrePD1, MFCCPD1, ChromaPD1};
   PDs0{jj} = {timbrePD0, MFCCPD0, ChromaPD0};
   fprintf(1, 'Finished speech %i\n', jj);
end
save('SpeechFeatures.mat', 'X', 'PDs1', 'PDs0');
