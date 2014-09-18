function [ Y ] = MuStdCenter( X )
    Y = bsxfun(@minus, mean(X, 1), X);
    Y = bsxfun(@times, 1./sqrt(var(Y, 1)), Y);
end