%Programmer: Chris Tralie
%Purpose: To make confusion matrix plots with and without TDA features
SongsPerGenre = 100;

genres = load('GTzanFeatures');
genres = genres.genres;
genresToTake = 1:10;
N = length(genresToTake);
NPrC = 5;
NNeighb = 3;

%With TDA
subplot(1, 3, 1);
ConfusionWTDA = doGTzanClassificationTest(genresToTake, SongsPerGenre, NPrC, NNeighb, 1);
imagesc(ConfusionWTDA);
Labels = genres(genresToTake);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title( sprintf('With TDA, %g Percent', 100*trace(ConfusionWTDA)/sum(ConfusionWTDA(:))) );
caxis([0, N*10]);
fprintf(1, 'Correct with TDA: %i\n', trace(ConfusionWTDA));

%Without TDA
subplot(1, 3, 2);
ConfusionWoTDA = doGTzanClassificationTest(genresToTake, SongsPerGenre, NPrC, NNeighb, 0);
imagesc(ConfusionWoTDA);
Labels = genres(genresToTake);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title( sprintf('Without TDA, %g Percent', 100*trace(ConfusionWoTDA)/sum(ConfusionWoTDA(:))) );
caxis([0, N*10]);
fprintf(1, 'Correct without TDA: %i\n', trace(ConfusionWoTDA));

%With Both
subplot(1, 3, 3);
ConfusionBoth = doGTzanClassificationTest(genresToTake, SongsPerGenre, NPrC, NNeighb, 2);
imagesc(ConfusionBoth);
Labels = genres(genresToTake);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title( sprintf('With Both, %g Percent', 100*trace(ConfusionBoth)/sum(ConfusionBoth(:))) );
caxis([0, N*10]);
fprintf(1, 'Correct without both: %i\n', trace(ConfusionBoth));