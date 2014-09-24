%Programmer: Chris Tralie
%Purpose: To perform a 10-fold cross-validation test on the GTzan data
%That is, randomly shuffle, then take 10 segments of 90% training 10% test

%Inputs:
%fOrig: 1000 x 59 vector of CAF features
%fDGM0: 1000 x 3kDGM0 vector of DGM0 features
%fDGM1: 1000 x 3kDGM1 vector of DGM1 features
%genresToUse: Indexes corresponding to the genres to use in this test
%SongsPerGenre: The number of songs per genre
%NNeighb: Number of neighbors to use in nearest neighbor classification
%randShuffle: Seed for the random number generated used to shuffle before
%cross-validation

%Returns:
%CCAF: Confusion matrix for CAF only
%CDGM0: Confusion matrix for DGM0 only
%CDGM1: Confusion matrix for DMG1 only
%CDGM01: Confusion matrix for DGM0 and DGM1
%CALL: Confusion matrix for all features
function [CCAF, CDGM0, CDGM1, CDGM01, CALL] = doGTzanClassificationTest(fOrig, fDGM0, fDGM1, genresToUse, SongsPerGenre, NNeighb, randSeed)
    %Pick the genres that should take place in this classification task
    NGenres = length(genresToUse);
    idx1 = repmat(1:SongsPerGenre, [NGenres, 1])';
    idx2 = repmat((genresToUse-1)*SongsPerGenre, [SongsPerGenre, 1]);
    idx = idx1(:) + idx2(:);
    fOrig = fOrig(idx, :);
    fDGM0 = fDGM0(idx, :);
    
    CCAF = zeros(NGenres, NGenres);
    CDGM0 = zeros(NGenres, NGenres);
    CDGM1 = zeros(NGenres, NGenres);
    CDGM01 = zeros(NGenres, NGenres);
    CALL = zeros(NGenres, NGenres);
    
    %This is assuming a texture window (so means/variances)
    timbreIndices = [1:4 30:33 59]; timbreIndices = [timbreIndices (timbreIndices + 59)];
    MFCCIndices = [5:9 34:38]; MFCCIndices = [MFCCIndices (MFCCIndices + 59)];
    ChromaIndices = [18:29 47:58]; ChromaIndices = [ChromaIndices (ChromaIndices + 59)];
    featuresIdx = [timbreIndices MFCCIndices ChromaIndices];
    
    %Shuffle songs
    s = RandStream('mcg16807', 'Seed', randSeed);
    idx = [];
    for ii = 0:SongsPerGenre:NGenres*SongsPerGenre-1
        idx = [idx (ii + s.randperm(SongsPerGenre))];
    end
    fOrig = fOrig(idx, :);
    fDGM0 = fDGM0(idx, :);
    fDGM1 = fDGM1(idx, :);
        
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
        fOrigTest = fOrig(testIdx, featuresIdx);
        fDGM0Train = fDGM0(trainIdx, :);
        fDGM1Train = fDGM1(trainIdx, :);
        fDGM0Test = fDGM0(testIdx, :);
        fDGM1Test = fDGM1(testIdx, :);

        %Step 2: Scale the CAF features for the training set so they each lie
        %in the range [0, 1]
        minOrig = min(fOrigTrain);
        fOrigTrain = bsxfun(@minus, fOrigTrain, minOrig);
        maxOrig = max(fOrigTrain);
        fOrigTrain = bsxfun(@times, fOrigTrain, 1./(maxOrig+eps));
        %Use the same weights to scale the test set
        fOrigTest = bsxfun(@minus, fOrigTest, minOrig);
        fOrigTest = bsxfun(@times, fOrigTest, 1./(maxOrig+eps));
        
        %Step 3: Scale the TDA features so they lie in the range [0, 1]
        minOrig = min(fDGM0Train);
        fDGM0Train = bsxfun(@minus, fDGM0Train, minOrig);
        maxOrig = max(fDGM0Train);
        fDGM0Train = bsxfun(@times, fDGM0Train, 1./(maxOrig+eps));
        fDGM0Test = bsxfun(@minus, fDGM0Test, minOrig);
        fDGM0Test = bsxfun(@times, fDGM0Test, 1./(maxOrig + eps));
        
        minOrig = min(fDGM1Train);
        fDGM1Train = bsxfun(@minus, fDGM1Train, minOrig);
        maxOrig = max(fDGM1Train);
        fDGM1Train = bsxfun(@times, fDGM1Train, 1./(maxOrig+eps));
        fDGM1Test = bsxfun(@minus, fDGM1Test, minOrig);
        fDGM1Test = bsxfun(@times, fDGM1Test, 1./(maxOrig + eps));

        %Step 4: Put the points into the full concatenated feature space
        %and do nearest neighbor.  Try 5 combinations of different groups
        %of features
        for useTDA = 0:4
            %CAF alone
            XTrain = fOrigTrain;
            XTest = fOrigTest;
            if useTDA == 1
                %DGM0 alone
                XTrain =  fDGM0Train;
                XTest = fDGM0Test;
            elseif useTDA == 2
                %DGM1 alone
                XTrain = fDGM1Train;
                XTest = fDGM1Test;
            elseif useTDA == 3
                %DGM0 and DGM1
                XTrain = [fDGM0Train fDGM1Train];
                XTest = [fDGM0Test fDGM1Test];
            elseif useTDA == 4
                XTrain = [fDGM0Train fDGM1Train fOrigTrain];
                XTest = [fDGM0Test fDGM1Test fOrigTest];
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
                   CDGM0(idxCorrect(kk), idxGuessed(kk)) = CDGM0(idxCorrect(kk), idxGuessed(kk)) + 1;
               end
               if useTDA == 2
                   CDGM1(idxCorrect(kk), idxGuessed(kk)) = CDGM1(idxCorrect(kk), idxGuessed(kk)) + 1;
               end
               if useTDA == 3
                   CDGM01(idxCorrect(kk), idxGuessed(kk)) = CDGM01(idxCorrect(kk), idxGuessed(kk)) + 1;
               end
               if useTDA == 4
                   CALL(idxCorrect(kk), idxGuessed(kk)) = CALL(idxCorrect(kk), idxGuessed(kk)) + 1;
               end
            end
        end
    end
end