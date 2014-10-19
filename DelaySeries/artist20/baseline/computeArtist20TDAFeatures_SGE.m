%Compute 0D and 1D rips filtrations based on subsampled MFCCs averaged
%in 10 second windows

ii = str2num(ii);

windowSize = 10;
globalSubsample = 15;%How much to downsample "global" 1D PCA point cloud
%to make 1D persistent homology more computationally feasible on the whole
%song

%The local 1D persistence parameters
%Hop by 1 second, do persistence in 5 second windows
MFCCSAMPLELEN = 0.016;
windowSizeLocal = 2;
windowLocal = floor(5/MFCCSAMPLELEN);
hopLocal = floor(2/MFCCSAMPLELEN);

addpath('../../../0DFiltrations');
addpath('../../');%Delay Series

filename = 'Artist20AllTDAFeatures.mat';

alltracks = '../lists/a20-all-tracks.list';

files = textread(alltracks, '%s\n');

fprintf(1, 'Doing %s\n', files{ii});

javaclasspath('jars/tda.jar');
import api.*;
tda = Tda();
[Y, MFCCWindowSize] = getSongPointCloud(files{ii}, windowSize, 1);
Y = bsxfun(@minus, mean(Y, 1), Y);
Y = bsxfun(@times, 1./std(Y), Y);
%Subsampled version
YGlobal = Y(1:globalSubsample:end, :);


%Compute morse filtrations
MorseDiagrams = getMorseFiltered0DDiagrams(Y, tda);

%Compute global 1D filtration with birthing/killing edges
[~, PD1Global, PD1GlobalBK] = getPersistenceDiagrams(YGlobal, tda);

%Compute mini sliding window 1D filtrations
YLocal = getSongPointCloud(files{ii}, windowSizeLocal, 1);
YLocal = bsxfun(@minus, mean(YLocal, 1), YLocal);
YLocal = bsxfun(@times, 1./std(YLocal), YLocal);
PDs1Local = getSlidingSliding1D(YLocal, hopLocal, windowLocal, tda);

fprintf(1, '==========  Finished %s  ==========\n', files{ii});
save(sprintf('%i.mat', ii), 'MorseDiagrams', 'PD1Global', 'PD1GlobalBK', 'PDs1Local');
