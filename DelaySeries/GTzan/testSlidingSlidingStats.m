load('GTzanFeaturesSlidingRips');
nbars = 0;
XOrig = cell2mat(featuresOrig');
XTDAMFCC = zeros(1000, nbars*4+2);
XTDATimbre = zeros(1000, nbars*4+2);
XTDAChroma = zeros(1000, nbars*4+2);

index = 1;
for ii = 1:10
   for jj = 1:100
       XTDAMFCC(index, :) = getSlidingSlidingWindowStats(allDGMs1MFCC{ii}{jj}, nbars);
       XTDATimbre(index, :) = getSlidingSlidingWindowStats(allDGMs1Timbre{ii}{jj}, nbars);
       XTDAChroma(index, :) = getSlidingSlidingWindowStats(allDGMs1Chroma{ii}{jj}, nbars);
       index = index + 1;
   end
end
XTDA = [XTDAChroma XTDAMFCC XTDATimbre];

XOrig = bsxfun(@minus, XOrig, mean(XOrig));
XOrig = bsxfun(@times, 1./std(XOrig), XOrig);
XTDA = bsxfun(@minus, XTDA, mean(XTDA));
XTDA = bsxfun(@times, 1./std(XTDA), XTDA);

%Shuffle songs
s = RandStream('mcg16807', 'Seed', 100);
idx = [];
for ii = 0:100:999
    idx = [idx (ii + s.randperm(100))];
end
XOrig = XOrig(idx, :);
XTDA = XTDA(idx, :);

%Do 10-fold cross-validation
NNeighb = 5;
CCAF = zeros(10, 10);
CTDA = zeros(10, 10);
for ii = 0:10:99
    %Step 1: Select the disjoint training and test sets
    idx1 = repmat(0:100:999, [10, 1]);
    idx2 = repmat(ii+(1:10), [10, 1])';
    testIdx = idx1(:) + idx2(:);
    trainIdx = 1:1000;
    trainIdx(testIdx) = -1;
    trainIdx = trainIdx(trainIdx > 0)';

    for useTDA = 0:1
        if useTDA == 0
            XTest = XOrig(testIdx, :);
            XTrain = XOrig(trainIdx, :);
        else
            XTest = XTDA(testIdx, :);
            XTrain = XTDA(trainIdx, :);
        end
        D = squareform(pdist([XTest; XTrain]));
        D = D(1:size(XTest, 1), size(XTest, 1)+1:end);
        [~, idx] = sort(D, 2);%Figure out the indexes of the closest points
        idx = idx(:, 1:NNeighb);
        idx = ceil(idx/90);

        %Step 3: Update the confusion matrix
        idxGuessed = mode(idx, 2);
        idxCorrect = repmat(1:10, [10, 1]);
        idxCorrect = idxCorrect(:);
        for kk = 1:length(idxGuessed)
           if useTDA == 0
               CCAF(idxCorrect(kk), idxGuessed(kk)) = CCAF(idxCorrect(kk), idxGuessed(kk)) + 1;
           end
           if useTDA == 1
               CTDA(idxCorrect(kk), idxGuessed(kk)) = CTDA(idxCorrect(kk), idxGuessed(kk)) + 1;
           end
        end
    end
end

N = 10;
imagesc(CCAF);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', genres);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', genres);
caxis([0, 100]);
title(sprintf('CAF %g Percent', 100*sum(diag(CCAF)/sum(CCAF(:)))));

figure;
imagesc(CTDA);
set(gca, 'YLim', [0 N+1], 'YTick', 1:N, 'YTickLabel', genres);
set(gca, 'XLim', [0 N+1], 'XTick', 1:N, 'XTickLabel', genres);
caxis([0, 100]);
title(sprintf('Sliding Sliding %g Percent', 100*sum(diag(CTDA)/sum(CTDA(:)))));