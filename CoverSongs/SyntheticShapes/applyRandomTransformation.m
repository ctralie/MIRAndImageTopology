function [ Y ] = applyRandomTransformation( X )
    dim = size(X, 2);
    R = randn(dim, dim);
    [R, ~] = svd(R);
    T = randn(1, size(X, 2));
    Y = X*R + repmat(T, [size(X, 1), 1]);
end