function [ NNF, NNFD, A ] = getKNN( D, K )
    N = size(D, 1);
    S1 = 1:N;
    [NNFD, NNF] = sort(D, 2);
    NNFD = NNFD(:, 2:K+1);
    NNF = NNF(:, 2:K+1);
    %Adjacency matrix
    A = sparse(repmat(S1(:), [K, 1]), NNF(:), ones(N*K, 1), N, N);
    A = (A + A');
    A(A > 0) = 1;
end
