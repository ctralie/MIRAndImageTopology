%Programmer: Chris Tralie
%Purpose: To do every possible 2-genre classification test and 
%see how using TDA improves
genres = load('GTzanFeatures');
genres = genres.genres;
NGenres = length(genres);
NPrC = 5;
NNeighb = 3;

D = zeros(NGenres, NGenres);
DTDA = zeros(NGenres, NGenres);

for ii = 1:NGenres
    ii
    for jj = ii+1:NGenres
        C = doGTzanClassificationTest([ii jj], NPrC, NNeighb, 0);
        CTDA = doGTzanClassificationTest([ii jj], NPrC, NNeighb, 1);
        score = trace(C)/sum(C(:));
        scoreTDA = trace(CTDA)/sum(CTDA(:));
        D(ii, jj) = score;
        DTDA(ii, jj) = scoreTDA;
    end
end
D = D + D' + eye(size(D, 1));
DTDA = DTDA + DTDA' + eye(size(DTDA, 1));
Improvement = DTDA - D;

colorRange = [min(min(DTDA(:)), min(D(:))), max(max(DTDA(:)), max(D(:)))];
subplot(2, 2, 1);
imagesc(DTDA);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', genres);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', genres);
title('With TDA');
caxis(colorRange);
colorbar;

subplot(2, 2, 2);
imagesc(D);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', genres);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', genres);
title('Without TDA');
caxis(colorRange);
colorbar;

subplot(2, 2, 3);
imagesc(Improvement);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', genres);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', genres);
colorbar;
title('Improvement');

subplot(2, 2, 4);
bar(mean(Improvement, 1));
set(gca, 'XTickLabel', genres);
title('Average Improvement');

fprintf(1, 'Average 2 Genre Accuracy without TDA: %g\n', mean(D(:)));
fprintf(1, 'Average 2 Genre Accuracy with TDA: %g\n', mean(DTDA(:)));