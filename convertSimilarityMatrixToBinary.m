function [ B ] = convertSimilarityMatrixToBinary( D,  kappa )
%kappa: The percentage of nearest neighbors to look for in each dimension
%of D
    N = size(D, 1);
    M = size(D, 2);
    B = zeros(N, M);
    [~, idxcol] = sort(D, 2);
    [~, idxrow] = sort(D, 1);
    cutoff1 = round(kappa*N);
    cutoff2 = round(kappa*M);
    B = (idxcol < cutoff2).*(idxrow < cutoff1);
    B = double(B);
end

