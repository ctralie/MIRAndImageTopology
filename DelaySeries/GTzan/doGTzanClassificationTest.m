%Programmer: Chris Tralie
%Purpose: To perform a 10-fold cross-validation test on the GTzan data
%That is, randomly shuffle, then take 10 segments of 90% training 10% test

%Inputs:
%genresToUse: Indexes corresponding to the genres to use in this test
%NPrC: Number of principal components to use for the TDA features
%NNeighb: Number of neighbors to use in nearest neighbor classification
%useTDA: Whether or not to use the TDA features

%Returns:
%Confusion: The confusion matrix
function [Confusion] = doGTzanClassificationTest(genresToUse, NPrC, NNeighb, useTDA)
    load('GTzanFeatures');
    fOrig = cell2mat(featuresOrig');
    fTDA = cell2mat(featuresTDA');

    %Pick the genres that should take place in this classification task
    NGenres = length(genresToUse);
    idx1 = repmat(1:100, [NGenres, 1])';
    idx2 = repmat((genresToUse-1)*100, [100, 1]);
    idx = idx1(:) + idx2(:);
    fOrig = fOrig(idx, :);
    fTDA = fTDA(idx, :);
    Confusion = zeros(NGenres, NGenres);

    %Shuffle songs
    idx = [];
    for ii = 0:100:NGenres*100-1
        idx = [idx (ii + randperm(100))];
    end
    fOrig = fOrig(idx, :);
    fTDA = fTDA(idx, :);

    %Do 10-fold cross-validation
    for ii = 0:10:99
        %Step 1: Select the disjoint training and test sets
        idx1 = repmat(0:100:NGenres*100-1, [10, 1]);
        idx2 = repmat(ii+(1:10), [NGenres, 1])';
        testIdx = idx1(:) + idx2(:);
        trainIdx = 1:100*NGenres;
        trainIdx(testIdx) = -1;
        trainIdx = trainIdx(trainIdx > 0)';

        fOrigTrain = fOrig(trainIdx, :);
        fTDATrain = fTDA(trainIdx, :);
        fOrigTest = fOrig(testIdx, :);
        fTDATest = fTDA(testIdx, :);

        %Step 2: Scale the CAF features for the training set so they each lie
        %in the range [0, 1]
        minOrig = min(fOrigTrain);
        fOrigTrain = bsxfun(@minus, fOrigTrain, minOrig);
        maxOrig = max(fOrigTrain);
        fOrigTrain = bsxfun(@times, fOrigTrain, 1./(maxOrig+eps));
        %Use the same weights to scale the test set
        fOrigTest = bsxfun(@minus, fOrigTest, minOrig);
        fOrigTest = bsxfun(@times, fOrigTest, 1./(maxOrig+eps));

        %Step 3: Do PCA on the TDA features for the training set and apply
        %those principal components to the testing and training set
        trainTDAProj = [];
        testTDAProj = [];
        for kk = 0:2
            indices = 1:200 + kk*200;
            thisfTDATrain = fTDATrain(:, indices);
            thisfTDATest = fTDATest(:, indices);
            PCATDA = pca(thisfTDATrain);
            PCATDA = PCATDA(:, 1:NPrC);
            %Center the features on their centroids
            thisfTDATrain = thisfTDATrain - repmat(mean(thisfTDATrain, 1), [size(thisfTDATrain, 1), 1]);
            thisfTDATest = thisfTDATest - repmat(mean(thisfTDATest, 1), [size(thisfTDATest, 1), 1]);
            %Project onto principal components
            trainTDAProj = [trainTDAProj (PCATDA'*thisfTDATrain')'];
            testTDAProj = [testTDAProj (PCATDA'*thisfTDATest')'];
        end

        %Step 4: Scale the PCA TDA features so they lie in the range [0, 1]
        minOrig = min(trainTDAProj);
        trainTDAProj = bsxfun(@minus, trainTDAProj, minOrig);
        maxOrig = max(trainTDAProj);
        trainTDAProj = bsxfun(@times, trainTDAProj, 1./(maxOrig+eps));
        testTDAProj = bsxfun(@minus, testTDAProj, minOrig);
        testTDAProj = bsxfun(@times, testTDAProj, 1./(maxOrig + eps));

        %Step 5: Put the points into the full concatenated feature space
        %and do nearest neighbor
        XTrain = fOrigTrain;
        XTest = fOrigTest;
        if useTDA == 1
            XTrain = [XTrain trainTDAProj];
            XTest = [XTest testTDAProj];
        end
        D = squareform(pdist([XTest; XTrain]));
        D = D(1:size(XTest, 1), size(XTest, 1)+1:end);
        [~, idx] = sort(D, 2);%Figure out the indexes of the closest points
        idx = idx(:, 1:NNeighb);
        idx = ceil(idx/90);
        
        %Step 6: Update the confusion matrix
        idxGuessed = mode(idx, 2);
        idxCorrect = repmat(1:NGenres, [10, 1]);
        idxCorrect = idxCorrect(:);
        for kk = 1:length(idxGuessed)
           Confusion(idxCorrect(kk), idxGuessed(kk)) = Confusion(idxCorrect(kk), idxGuessed(kk)) + 1;
        end
    end
end