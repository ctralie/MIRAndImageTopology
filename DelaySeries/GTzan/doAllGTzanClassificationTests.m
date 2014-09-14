%Programmer: Chris Tralie
%Purpose: To make confusion matrix plots with and without TDA features

%Step 1: Load the CAF features and compute the TDA features from the
%saved diagrams
load('GTzanFeatures');
fOrig = cell2mat(featuresOrig');
fTDA = getSortedBars(AllPDs1, 1, 100);

SongsPerGenre = 100;

genres = load('GTzanFeatures');
genres = genres.genres;
genresToTake = 1:10;
N = length(genresToTake);
NPrC = 5;
NNeighb = 5;

%With TDA
subplot(2, 2, 1);
[ConfusionCAF, ConfusionTDA, ConfusionBoth] = doGTzanClassificationTest(fOrig, fTDA, genresToTake, SongsPerGenre, NPrC, NNeighb);
imagesc(ConfusionTDA);
Labels = genres(genresToTake);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title( sprintf('With TDA, %g Percent', 100*trace(ConfusionTDA)/sum(ConfusionTDA(:))) );
caxis([0, N*10]);
fprintf(1, 'Correct with TDA: %i\n', trace(ConfusionTDA));

%Without TDA
subplot(2, 2, 2);
imagesc(ConfusionCAF);
Labels = genres(genresToTake);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title( sprintf('With CAF, %g Percent', 100*trace(ConfusionCAF)/sum(ConfusionCAF(:))) );
caxis([0, N*10]);
fprintf(1, 'Correct with CAF: %i\n', trace(ConfusionCAF));

%With Both
subplot(2, 2, 3);
imagesc(ConfusionBoth);
Labels = genres(genresToTake);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title( sprintf('With Both, %g Percent', 100*trace(ConfusionBoth)/sum(ConfusionBoth(:))) );
caxis([0, N*10]);
fprintf(1, 'Correct with both: %i\n', trace(ConfusionBoth));

subplot(2, 2, 4);
imagesc(ConfusionBoth - ConfusionCAF);
Labels = genres(genresToTake);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
colorbar;
title('Difference when TDA Added');