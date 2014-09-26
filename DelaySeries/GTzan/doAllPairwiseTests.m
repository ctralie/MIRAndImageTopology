%Programmer: Chris Tralie
%Purpose: To do every possible 2-genre classification test and 
%see how using TDA improves

NNeighb = 5;

doPCA = 0;
NPrC = 5;
NFourier = 5;

startbar0 = 1;
endbar0 = 4000;
nbars0 = endbar0 - startbar0 + 1;
startbar1 = 1;
endbar1 = 100;
nbars1 = endbar1 - startbar1 + 1;
SongsPerGenre = 100;
randSeed = 100;%Change this to change the permutation order used before
%cross-validation

%Load the CAF features and compute the TDA features from the
%saved diagrams
savedFeatures = load('GTzanFeatures_ScaledSamePredetermined');
genres = savedFeatures.genres;
for ii = 1:length(genres)
    genres{ii} = genres{ii}(1:3);
end
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

CCAFPairs = zeros(10, 10);
CDGM0Pairs = zeros(10, 10);
CDGM1Pairs = zeros(10, 10);
CDGM01Pairs = zeros(10, 10);
CALLPairs = zeros(10, 10);
for ii = 1:10
    ii
    for jj = ii+1:10
        [CCAF, CDGM0, CDGM1, CDGM01, CALL] = ...
            doGTzanClassificationTest(fOrig, fDGM0, fDGM1, [ii jj], SongsPerGenre, NNeighb, randSeed);
        CCAFPairs(ii, jj) = trace(CCAF);
        CDGM0Pairs(ii, jj) = trace(CDGM0);
        CDGM1Pairs(ii, jj) = trace(CDGM1);
        CDGM01Pairs(ii, jj) = trace(CDGM01);
        CALLPairs(ii, jj) = trace(CALL);
    end
end
    
N = 10;
Labels = genres;

%CAF only
subplot(3, 3, 1);
imagesc(CCAFPairs);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title( 'CAF' );
caxis([0, 200]);


%DGM0
subplot(3, 3, 2);
imagesc(CDGM0Pairs);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title( 'DGM0' );
caxis([0, 200]);


%DGM0 Diff
subplot(3, 3, 3);
imagesc(CDGM0Pairs - CCAFPairs);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title( 'DGM0 Diff' );
caxis([0, max(max(CDGM0Pairs - CCAFPairs))]);
colorbar;

%DGM1
subplot(3, 3, 5);
imagesc(CDGM1Pairs);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title( 'DGM1' );
caxis([0, 200]);


%DGM1 Diff
subplot(3, 3, 6);
imagesc(CDGM1Pairs - CCAFPairs);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title( 'DGM1 Diff' );
caxis([0, max(max(CDGM1Pairs - CCAFPairs))]);
colorbar;


%DGM01
subplot(3, 3, 8);
imagesc(CDGM01Pairs);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title( 'DGM1 and DGM0' );
caxis([0, 200]);

%DGM01 Diff
subplot(3, 3, 9);
imagesc(CDGM01Pairs - CCAFPairs);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title( 'DGM01 Diff' );
caxis([0, max(max(CDGM01Pairs - CCAFPairs))]);
colorbar;

%All
subplot(3, 3, 4);
imagesc(CALLPairs);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title( 'All' );
caxis([0, 200]);

