%Programmer: Chris Tralie
%Purpose: To perform a 10-fold cross-validation test on the GTzan data
%That is, randomly shuffle, then take 10 segments of 90% training 10% test

%Inputs:
%fOrig: 1000 x 59 vector of CAF features
%fTDA: 1000 x 3kTDA vector of TDA features
%genresToUse: Indexes corresponding to the genres to use in this test
%SongsPerGenre: The number of songs per genre
%NPrC: Number of principal components to use for the TDA features
%NNeighb: Number of neighbors to use in nearest neighbor classification

%Returns:
%CTDA: Confusion matrix for TDA only
%CCAF: Confusion matrix for CAF only
%CBOTH: Confusion matrix for both
function [CCAF, CTDA, CBOTH] = doGTzanClassificationTest(fOrig, fTDA, genresToUse, SongsPerGenre, NPrC, NNeighb)
    %Pick the genres that should take place in this classification task
    NGenres = length(genresToUse);
    idx1 = repmat(1:SongsPerGenre, [NGenres, 1])';
    idx2 = repmat((genresToUse-1)*SongsPerGenre, [SongsPerGenre, 1]);
    idx = idx1(:) + idx2(:);
    fOrig = fOrig(idx, :);
    fTDA = fTDA(idx, :);
    kTDA = size(fTDA, 2)/3;%Used to split the TDA features into timbral, chroma, mfcc
    
    CCAF = zeros(NGenres, NGenres);
    CTDA = zeros(NGenres, NGenres);
    CBOTH = zeros(NGenres, NGenres);
    
    %This is assuming a texture window (so means/variances)
    timbreIndices = [1:4 30:33 59]; timbreIndices = [timbreIndices (timbreIndices + 59)];
    MFCCIndices = [5:9 34:38]; MFCCIndices = [MFCCIndices (MFCCIndices + 59)];
    ChromaIndices = [18:29 47:58]; ChromaIndices = [ChromaIndices (ChromaIndices + 59)];
    featuresIdx = [timbreIndices MFCCIndices ChromaIndices];
    
    %Shuffle songs
    idx = [];
    for ii = 0:SongsPerGenre:NGenres*SongsPerGenre-1
        idx = [idx (ii + randperm(SongsPerGenre))];
    end
    fOrig = fOrig(idx, :);
    fTDA = fTDA(idx, :);

    %Do 10-fold cross-validation
    for ii = 0:SongsPerGenre/10:SongsPerGenre-1
        %Step 1: Select the disjoint training and test sets
        idx1 = repmat(0:SongsPerGenre:NGenres*SongsPerGenre-1, [SongsPerGenre/10, 1]);
        idx2 = repmat(ii+(1:SongsPerGenre/10), [NGenres, 1])';
        testIdx = idx1(:) + idx2(:);
        trainIdx = 1:SongsPerGenre*NGenres;
        trainIdx(testIdx) = -1;
        trainIdx = trainIdx(trainIdx > 0)';
        
        fOrigTrain = fOrig(trainIdx, featuresIdx);
        fTDATrain = fTDA(trainIdx, :);
        fOrigTest = fOrig(testIdx, featuresIdx);
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
            indices = 1:kTDA + kk*kTDA;
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
        %and do nearest neighbor.  Try CAF alone, TDA alone, and both
        for useTDA = 0:2
            %CAF alone
            XTrain = fOrigTrain;
            XTest = fOrigTest;
            if useTDA == 1
                %TDA Alone
                XTrain=  trainTDAProj;
                XTest = testTDAProj;
            elseif useTDA == 2
                %BOth
                XTrain = [fOrigTrain trainTDAProj];
                XTest = [fOrigTest testTDAProj];
            end
            D = squareform(pdist([XTest; XTrain]));
            D = D(1:size(XTest, 1), size(XTest, 1)+1:end);
            [~, idx] = sort(D, 2);%Figure out the indexes of the closest points
            idx = idx(:, 1:NNeighb);
            idx = ceil(idx/(SongsPerGenre*9.0/10.0));

            %Step 6: Update the confusion matrix
            idxGuessed = mode(idx, 2);
            idxCorrect = repmat(1:NGenres, [SongsPerGenre/10, 1]);
            idxCorrect = idxCorrect(:);
            for kk = 1:length(idxGuessed)
               if useTDA == 0
                   CCAF(idxCorrect(kk), idxGuessed(kk)) = CCAF(idxCorrect(kk), idxGuessed(kk)) + 1;
               end
               if useTDA == 1
                   CTDA(idxCorrect(kk), idxGuessed(kk)) = CTDA(idxCorrect(kk), idxGuessed(kk)) + 1;
               end
               if useTDA == 2
                   CBOTH(idxCorrect(kk), idxGuessed(kk)) = CBOTH(idxCorrect(kk), idxGuessed(kk)) + 1;
               end
            end
        end
    end
end