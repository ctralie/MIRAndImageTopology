%Programmer: Chris Tralie
%Purpose: To train and test a linear SVM on every pair of genres

%Parameters to vary
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
%Load the CAF features and compute the TDA features from the
%saved diagrams
%savedFeatures = load('GTzanFeatures_ScaledSamePredetermined');
savedFeatures = load('GTzanFeatures_ScaledBySong');
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

%Do permutation test on all pairs of genres, for each of CAF, DGM0, and
%DGM1
CAFResults = eye(10);
DGM0Results = eye(10);
DGM1Results = eye(10);
for ii = 1:10
    ii
    idx1 = (1:100) + ((ii-1)*100);
    for jj = ii+1:10
        idx2 = (1:100) + ((jj-1)*100);
        %Do CAF SVM
        CAFResults(ii, jj) = SVM10Fold(fOrig, idx1, idx2);
        DGM0Results(ii, jj) = SVM10Fold(fDGM0, idx1, idx2);
        DGM1Results(ii, jj) = SVM10Fold(fDGM1, idx1, idx2);
    end
end

save('GTzanSVM.mat', 'CAFResults', 'DGM0Results', 'DGM1Results', 'genres');

N = length(genres);

subplot(2, 2, 1);
imagesc(CAFResults);
title('CAF');
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', genres);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', genres);

subplot(2, 2, 2);
imagesc(DGM0Results);
title('DGM0');
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', genres);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', genres);

subplot(2, 2, 3);
imagesc(DGM1Results);
title('DGM1');
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', genres);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', genres);