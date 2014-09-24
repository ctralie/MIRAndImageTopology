%Programmer: Chris Tralie
%Purpose: To extract the CAF and 1D rips filtration features from the George
%Tzanetakis 2002 dataset
%indices: The indices of the genres to compute (Useful to run this file
%on different cores with different indices to parallelize computation)
function [] = computeGTzanRipsFiltrations(indices, SongsPerGenre, subsample, foldername)
    addpath('genres');
    addpath('..');
    addpath('../chroma-ansyn');
    addpath('../rastamat');
    genres = {'blues', 'classical', 'country', 'disco', 'hiphop', 'jazz', 'metal', 'pop', 'reggae', 'rock'};
    hopSize = 512;
    NWin = 43;
    
    if nargin < 3
        subsample = 1;
    end
    if nargin < 4
        foldername = '.'; 
    end
    %This is assuming a texture window (so means/variances)
    timbreIndices = [1:4 30:33 59];
    MFCCIndices = [5:9 34:38];
    ChromaIndices = [18:29 47:58];

%     ScalingInfo = load('ScalingInfo');
%     ScaleMeans = ScalingInfo.means;
%     ScaleSTDevs = sqrt(ScalingInfo.vars);
    
    AllPDs0 = cell(1, length(indices));
    AllPDs1 = cell(1, length(indices));
    AllPDs1BK = cell(1, length(indices));
    featuresOrig = cell(1, length(indices));
    for ii = 1:length(indices)
       genre = genres{indices(ii)};
       fprintf(1, 'Doing %s...\n', genre);
       X = zeros(SongsPerGenre, 59*2);
       PDs0 = cell(SongsPerGenre, 1);
       PDs1 = cell(SongsPerGenre, 1);
       PDs1BK = cell(SongsPerGenre, 1);
       parfor jj = 1:SongsPerGenre
           filename = sprintf('genres/%s/%s.%.5i.au', genre, genre, jj-1);
           DelaySeries = getDelaySeriesFeatures(filename, hopSize, 1, NWin);
           %Save the mean and variance of all features to "featuresOrig"
           thisX = [mean(DelaySeries, 1) sqrt(var(DelaySeries, 1))];
           X(jj, :) = thisX;
           %Now scale the delay series by the mean and standard deviation
           %in this song
           ScaleMeans = mean(DelaySeries, 1);
           ScaleSTDevs = std(DelaySeries);
           DelaySeries = bsxfun(@minus, DelaySeries, ScaleMeans);
           DelaySeries = bsxfun(@times, DelaySeries, 1./ScaleSTDevs);
           %Do DGM1 separately for timbre, MFCC, and chroma
           %Subsample the point clouds by a factor of 2
           [timbrePD0, timbrePD1, timbrePD1BK] = getPersistenceDiagrams(DelaySeries(1:subsample:end, timbreIndices));
           [MFCCPD0, MFCCPD1, MFCCPD1BK] = getPersistenceDiagrams(DelaySeries(1:subsample:end, MFCCIndices));
           [ChromaPD0, ChromaPD1, ChromaPD1BK] = getPersistenceDiagrams(DelaySeries(1:subsample:end, ChromaIndices));
           fprintf(1, 'Finished %s %i\n', genre, jj);
           PDs0{jj} = {timbrePD0, MFCCPD0, ChromaPD0};
           PDs1{jj} = {timbrePD1, MFCCPD1, ChromaPD1};
           PDs1BK{jj} = {timbrePD1BK, MFCCPD1BK, ChromaPD1BK};
       end
       AllPDs0{ii} = PDs0;
       AllPDs1{ii} = PDs1;
       AllPDs1BK{ii} = PDs1BK;
       featuresOrig{ii} = X;
       save(sprintf('%s/GTzanFeatures%i.mat', foldername, indices(ii)), 'X', 'PDs0', 'PDs1', 'PDs1BK', 'genres');
    end
    save(sprintf('%s/GTzanFeatures.mat', foldername), 'AllPDs0', 'AllPDs1', 'AllPDs1BK', 'featuresOrig', 'genres');
end
