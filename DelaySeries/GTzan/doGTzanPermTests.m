%Programmer: Chris Tralie
%Purpose: To do permutation tests for the Tzanetakis features

%Parameters to vary
NPerms = 50000;%500000;

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
PsCAF = zeros(10, 10);
PsDGM1 = zeros(10, 10);
PsDGM0 = zeros(10, 10);
parfor ii = 1:10
    PsCAFRow = zeros(1, 10);
    PsDGM1Row = zeros(1, 10);
    PsDGM0Row = zeros(1, 10);
    for jj = ii+1:10
        songIndices = [(ii-1)*100 + (1:100), (jj-1)*100 + (1:100)];
        CAFs = fOrig(songIndices, :);
        DGM0 = fDGM0(songIndices, :);
        DGM1 = fDGM1(songIndices, :);
        
        %True mean differences
        deltaCAF = getMeanDiff(CAFs, 100);
        deltaDGM0 = getMeanDiff(DGM0, 100);
        deltaDGM1 = getMeanDiff(DGM1, 100);
        
        CAFGreater = 0;
        DGM0Greater = 0;
        DGM1Greater = 0;
        fprintf(1, 'Doing Permutation test for %s vs %s...\n', genres{ii}, genres{jj});
        for kk = 1:NPerms
            idx = randperm(200);
            CAFs = fOrig(songIndices(idx), :);
            DGM0 = fDGM0(songIndices(idx), :);
            DGM1 = fDGM1(songIndices(idx), :);
            if getMeanDiff(CAFs, 100) > deltaCAF
               CAFGreater = CAFGreater + 1; 
            end
            if getMeanDiff(DGM0, 100) > deltaDGM0
               DGM0Greater = DGM0Greater + 1; 
            end
            if getMeanDiff(DGM1, 100) > deltaDGM1
               DGM1Greater = DGM1Greater + 1; 
            end
        end
        
        clf;
        subplot(2, 2, 1);
        text(0.3, 0.5, sprintf('%s vs %s', genres{ii}, genres{jj}));

        subplot(2, 2, 2);
        Y = cmdscale(squareform(pdist(fOrig(songIndices, :))));
        plot(Y(1:100, 1), Y(1:100, 2), 'b.');hold on;plot(Y(101:end, 1), Y(101:end, 2), 'r.');
        title(sprintf('CAF, p = %g', CAFGreater / NPerms));
        PsCAFRow(jj) = CAFGreater / NPerms;

        subplot(2, 2, 3);
        Y = cmdscale(squareform(pdist(fDGM0(songIndices, :))));
        plot(Y(1:100, 1), Y(1:100, 2), 'b.');hold on;plot(Y(101:end, 1), Y(101:end, 2), 'r.');
        title(sprintf('DGM0, p = %g', DGM0Greater / NPerms));
        PsDGM0Row(jj) = DGM0Greater / NPerms;

        subplot(2, 2, 4);
        Y = cmdscale(squareform(pdist(fDGM1(songIndices, :))));
        plot(Y(1:100, 1), Y(1:100, 2), 'b.');hold on;plot(Y(101:end, 1), Y(101:end, 2), 'r.');
        title(sprintf('DGM1, p = %g', DGM1Greater / NPerms));
        PsDGM1Row(jj) = DGM1Greater / NPerms;
        
        print('-dpng', '-r100', sprintf('%i_%i.png', ii, jj));
        fprintf(1, 'Finished %s vs %s...\n', genres{ii}, genres{jj});
    end
    PsCAF(ii, :) = PsCAFRow;
    PsDGM1(ii, :) = PsDGM1Row;
    PsDGM0(ii, :) = PsDGM0Row;
end

save('PermutationTests.mat', 'PsCAF', 'PsDGM0', 'PsDGM1', 'genres');

N = length(genres);
imagesc(PsDGM1);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', genres);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', genres);
title( 'Ps DGM1' );
caxis([0, 0.05]);
colorbar;