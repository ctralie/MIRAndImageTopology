%Programmer: Chris Tralie
%Purpose: To do 1D rips on the analysis windows within every texture window
function [] = computeGTzanSlidingRipsFiltrations(indices, SongsPerGenre)
    init;
    rca1pc(rand(100, 2), 100);
    addpath('genres');
    addpath('..');
    addpath('../chroma-ansyn');
    addpath('../rastamat');
    genres = {'blues', 'classical', 'country', 'disco', 'hiphop', 'jazz', 'metal', 'pop', 'reggae', 'rock'};
    hopSize = 512;
    NWin = 43;
    
    %This is assuming a texture window (so means/variances)
    timbreIndices = [1:4 30:33 59];
    MFCCIndices = [5:9 34:38];
    ChromaIndices = [18:29 47:58];
    
    featuresOrig = cell(1, length(indices));
    allDGMs1Chroma = cell(1, length(indices));
    allDGMs1MFCC = cell(1, length(indices));
    allDGMs1Timbre = cell(1, length(indices));
    
    for ii = 1:length(indices)
       genre = genres{indices(ii)};
       fprintf(1, 'Doing %s...\n', genre);
       X = zeros(SongsPerGenre, 59*2);
       DGMs1Chroma = cell(SongsPerGenre, 1);
       DGMs1MFCC = cell(SongsPerGenre, 1);
       DGMs1Timbre = cell(SongsPerGenre, 1);
       
       for jj = 1:SongsPerGenre
           filename = sprintf('genres/%s/%s.%.5i.au', genre, genre, jj-1);
           DelaySeries = getDelaySeriesFeatures(filename, hopSize, 1, NWin);
           %Save the mean and variance of all features to "featuresOrig"
           thisX = [mean(DelaySeries, 1) sqrt(var(DelaySeries, 1))];
           X(jj, :) = thisX;
           
           %Now get the analysis windows averaged
           DelaySeries = getDelaySeriesFeatures(filename, hopSize, 1, 10);
           
           %Now scale the delay series by the mean and standard deviation
           %in this song
           ScaleMeans = mean(DelaySeries, 1);
           ScaleSTDevs = std(DelaySeries);
           DelaySeries = bsxfun(@minus, DelaySeries, ScaleMeans);
           DelaySeries = bsxfun(@times, DelaySeries, 1./ScaleSTDevs);
           
           %Do DGM1 in sliding windows for each of timbre, MFCC, and Chroma
           idx = 1:NWin:size(DelaySeries, 1)-NWin-1;
           N = length(idx);
           DGMs1Chroma{jj} = cell(N, 1);
           DGMs1MFCC{jj} = cell(N, 1);
           DGMs1Timbre{jj} = cell(N, 1);
           for kk = 1:N
               fprintf(1, 'Finished %i of %i for %s %i\n', kk, N, genre, jj);
               [DGMs1Timbre{jj}{kk}, ~] = rca1pc(DelaySeries(idx(kk):idx(kk)+NWin-1, timbreIndices), 1000);
               [DGMs1Chroma{jj}{kk}, ~] = rca1pc(DelaySeries(idx(kk):idx(kk)+NWin-1, ChromaIndices), 1000);
               [DGMs1MFCC{jj}{kk}, ~] = rca1pc(DelaySeries(idx(kk):idx(kk)+NWin-1, MFCCIndices), 1000);
           end
           
           fprintf(1, 'Finished %s %i\n', genre, jj);
       end
       allDGMs1Chroma{ii} = DGMs1Chroma;
       allDGMs1MFCC{ii} = DGMs1MFCC;
       allDGMs1Timbre{ii} = DGMs1Timbre;
       featuresOrig{ii} = X;
       save('GTzanFeaturesSlidingRips.mat', 'allDGMs1Chroma', 'allDGMs1MFCC', 'allDGMs1Timbre', 'featuresOrig', 'genres');
    end
    save('GTzanFeaturesSlidingRips.mat', 'allDGMs1Chroma', 'allDGMs1MFCC', 'allDGMs1Timbre', 'featuresOrig', 'genres');
end
