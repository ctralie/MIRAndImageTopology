function [ Y ] = getDelayEmbedding( X, M )
    N = size(X, 1);
    k = size(X, 2);
    Y = zeros(N-M+1, k*M);
    for ii = 1:size(Y, 1)
        y = X(ii:ii+M-1, :);
        Y(ii, :) = y(:)';
    end
end

