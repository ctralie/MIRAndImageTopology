%Programmer: Chris Tralie
%Purpose: To make confusion matrix plots with and without TDA features
genres = load('GTzanFeatures');
genres = genres.genres;
genresToTake = 1:9;
N = length(genresToTake);
NPrC = 5;
NNeighb = 3;

%With TDA
subplot(1, 2, 1);
ConfusionWTDA = doGTzanClassificationTest(genresToTake, NPrC, NNeighb, 1);
imagesc(ConfusionWTDA);
Labels = genres(genresToTake);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title( sprintf('With TDA, %g Percent', 100*trace(ConfusionWTDA)/sum(ConfusionWTDA(:))) );
caxis([0, N*10]);
fprintf(1, 'Correct with TDA: %i\n', trace(ConfusionWTDA));

%Without TDA
subplot(1, 2, 2);
ConfusionWoTDA = doGTzanClassificationTest(genresToTake, NPrC, NNeighb, 0);
imagesc(ConfusionWoTDA);
Labels = genres(genresToTake);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title( sprintf('Without TDA, %g Percent', 100*trace(ConfusionWoTDA)/sum(ConfusionWoTDA(:))) );
caxis([0, N*10]);
fprintf(1, 'Correct without TDA: %i\n', trace(ConfusionWoTDA));