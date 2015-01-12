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
    size(X)
    size(Y)
    D = X - Y;
    D = squeeze(sum(D.^wassexp, 3)).^(1.0/wassexp);
    
    %If there are more points in one than the other, pad
    %with vertical matchings to the diagonal in the persistence diagram
    if N < M
        bottom = T(:, 2) - T(:, 1);
        bottom = repmat(bottom(:)', [M - N, 1]);
        D = [D; bottom];
    elseif M < N
        right = S(:, 2) - S(:, 1);
        right = repmat(right(:), [1, N - M]);
        D = [D right];
    end
    %Make use of an externally written Hungarian algorithm file
    [matchidx, matchdist] = Hungarian(D);
end