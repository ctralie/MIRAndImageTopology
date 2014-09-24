%Programmer: Chris Tralie
%Purpose: To make confusion matrix plots with and without TDA features

%Parameters to vary
NNeighb = 5;

doPCA = 0;
NPrC = 5;
NFourier = 6;

startbar0 = 1;
endbar0 = 4000;
nbars0 = endbar0 - startbar0 + 1;
startbar1 = 1;
endbar1 = 100;
nbars1 = endbar1 - startbar1 + 1;
SongsPerGenre = 100;
genresToTake = 1:10;
randSeed = 100;%Change this to change the permutation order used before
%cross-validation

%Load the CAF features and compute the TDA features from the
%saved diagrams
savedFeatures = load('GTzanFeatures_ScaledSamePredetermined');
genres = savedFeatures.genres;
dgms1 = savedFeatures.AllPDs1;%1D persistence diagrams
fOrig = cell2mat(savedFeatures.featuresOrig');%CAF Features
dgms0 = load('GTzanMorseDiagrams');
dgms0 = dgms0.morseDiagrams;%0D persistence diagrams

if doPCA == 1
    fDGM0Raw = zeros(3, 1000, nbars0);
    fDGM1Raw = zeros(3, 1000, nbars1*2);
    for ii = 1:10
       for jj = 1:100
          idx = (ii-1)*100 + jj;
          for kk = 1:3 %Timbre, MFCC, Chroma
              fDGM0Raw(kk, idx, :) = getSortedBars(dgms0{ii}{jj}{kk}, startbar0, endbar0, 0);
              fDGM1Raw(kk, idx, :) = getSortedBars(dgms1{ii}{jj}{kk}, startbar1, endbar1, 1);
          end
       end
    end
    fDGM0 = [];
    fDGM1 = [];
    for kk = 1:3
        %Do PCA on each group of features
        [~, PCA0] = pca(squeeze(fDGM0Raw(kk, :, :)));
        [~, PCA1] = pca(squeeze(fDGM1Raw(kk, :, :)));
        fDGM0 = [fDGM0 PCA0(:, 1:NPrC)];
        fDGM1 = [fDGM1 PCA1(:, 1:NPrC)];
    end
else
    fDGM0 = zeros(1000, NFourier*3);%Truncated fourier of lifetimes for timbre, mfcc, chroma
    fDGM1 = zeros(1000, (NFourier+2)*3);%Truncated fourier of lifetimes plus mean/variance of birth times for timbre, mfcc, chroma
    for ii = 1:10
       for jj = 1:100
          idx = (ii-1)*100 + jj;
          thisfDGM0 = [];
          thisfDGM1 = [];
          for kk = 1:3 %Timbre, MFCC, Chroma
              sortedBars0 = getSortedBars(dgms0{ii}{jj}{kk}, startbar0, endbar0, 0);
              bars0fft = abs(fft(sortedBars0));
              thisfDGM0 = [thisfDGM0; bars0fft(1:NFourier)];%Take truncated fourier coefficients for DGM0

              sortedBars1 = getSortedBars(dgms1{ii}{jj}{kk}, startbar1, endbar1, 1);
              bars1fft = abs(fft(sortedBars1(1:nbars1)));
              thisfDGM1 = [thisfDGM1; bars1fft(1:NFourier); mean(sortedBars1(nbars1+1:end)); std(sortedBars1(nbars1+1:end))];
          end
          fDGM0(idx, :) = thisfDGM0;
          fDGM1(idx, :) = thisfDGM1;
       end
    end
end



[CCAF, CDGM0, CDGM1, CDGM01, CALL] = doGTzanClassificationTest(fOrig, fDGM0, fDGM1, genresToTake, SongsPerGenre, NNeighb, randSeed);

N = length(genresToTake);
Labels = genres(genresToTake);

%CAF only
subplot(3, 2, 1);
imagesc(CCAF);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title( sprintf('CAF, %g Percent', 100*trace(CCAF)/sum(CCAF(:))) );
caxis([0, SongsPerGenre]);
fprintf(1, 'Correct with CAF: %i\n', trace(CCAF));

%DGM0 only
subplot(3, 2, 2);
imagesc(CDGM0);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title( sprintf('DGM0, %g Percent', 100*trace(CDGM0)/sum(CDGM0(:))) );
caxis([0, SongsPerGenre]);
fprintf(1, 'Correct with DGM0: %i\n', trace(CDGM0));


%DGM1 only
subplot(3, 2, 3);
imagesc(CDGM1);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title( sprintf('DGM1, %g Percent', 100*trace(CDGM1)/sum(CDGM1(:))) );
caxis([0, SongsPerGenre]);
fprintf(1, 'Correct with DGM1: %i\n', trace(CDGM1));


%DGM0 and DGM1
subplot(3, 2, 4);
imagesc(CDGM01);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title( sprintf('DGM0 and DGM1, %g Percent', 100*trace(CDGM01)/sum(CDGM01(:))) );
caxis([0, SongsPerGenre]);
fprintf(1, 'Correct with DGM0 and DGM1: %i\n', trace(CDGM01));


%DGM0 only
subplot(3, 2, 5);
imagesc(CALL);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title( sprintf('All, %g Percent', 100*trace(CALL)/sum(CALL(:))) );
caxis([0, SongsPerGenre]);
fprintf(1, 'Correct with All: %i\n', trace(CALL));