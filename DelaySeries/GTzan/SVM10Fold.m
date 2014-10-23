function [ rate ] = SVM10Fold( X, idx1, idx2 )
    N = length(idx1);
    idx1p = idx1(randperm(N));
    idx2p = idx2(randperm(N));
    rate = 0;
    for fold = 1:10
        testIdx = ((fold-1)*N/10) + (1:(N/10));
        trainIdx = 1:N;
        trainIdx(testIdx) = -1;
        trainIdx = trainIdx(trainIdx > 0);
        
        try
        svmStruct = svmtrain([X(idx1p(trainIdx), :); X(idx2p(trainIdx), :)], ...
        [ones(length(trainIdx), 1); 2*ones(length(trainIdx), 1)]);
    
        C = zeros(2, 2);
        for ii = 1:length(testIdx)
            class = svmclassify(svmStruct, X(idx1p(testIdx(ii)), :));
            C(1, class) = C(1, class) + 1;
            class = svmclassify(svmStruct, X(idx2p(testIdx(ii)), :));
            C(2, class) = C(2, class) + 1;
        end
        rate = rate + sum(diag(C))/sum(C(:));
        catch err
           err
        end
    end
    rate = rate/10;
end

