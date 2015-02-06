%Inputs: 
%S: A Nx2 array of persistence points for the first diagram
%T: A Mx2 array of persistence points for the second diagram
%wassexp: The type of the norm (L2 default)
function [ matchidx, matchdist, D ] = getWassersteinDist( S, T, wassexp )
    if nargin < 3
        wassexp = 2;
    end
    N = size(S, 1);
    M = size(T, 1);
    
    %Step 1:Compute Distance Matrix
    X = reshape(S, [size(S, 1), 1, size(S, 2)]);
    X = repmat(X, [1, size(T, 1), 1]);
    Y = reshape(T, [1, size(T, 1), size(T, 2)]);
    Y = repmat(Y, [size(S, 1), 1, 1]);
    DUL = X - Y;
    DUL = squeeze(sum(DUL.^wassexp, 3)).^(1.0/wassexp);
    
    %Put diagonal elements
    D = zeros(N+M, N+M);
    D(1:N, 1:M) = DUL;
    D(N+1:end, 1:M) = repmat(T(:, 2)-T(:, 1), [1, M]);
    D(1:N, M+1:end) = repmat((S(:, 2)-S(:, 1))', [N, 1]);
    
    
    
    %Make use of an externally written Hungarian algorithm file
    [matchidx, matchdist] = Hungarian(D);
end