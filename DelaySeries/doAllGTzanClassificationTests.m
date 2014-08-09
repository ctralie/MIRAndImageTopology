genres = load('GTzanFeatures');
genres = genres.genres;
genresToTake = 1:10;
N = length(genresToTake);
NPrC = 5;
NNeighb = 3;

%With TDA
ConfusionWTDA = doGTzanClassificationTest(genresToTake, NPrC, NNeighb, 1);
imagesc(ConfusionWTDA);
Labels = genres(genresToTake);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title('With TDA');
caxis([0, N*10]);
fprintf(1, 'Correct with TDA: %i\n', trace(ConfusionWTDA));

%Without TDA
figure;
ConfusionWoTDA = doGTzanClassificationTest(genresToTake, NPrC, NNeighb, 0);
imagesc(ConfusionWoTDA);
Labels = genres(genresToTake);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', Labels);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', Labels);
title('Without TDA');
caxis([0, N*10]);
fprintf(1, 'Correct without TDA: %i\n', trace(ConfusionWoTDA));