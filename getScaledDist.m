function [ D, X ] = getScaledDist( X, type )
    if type == 1
        %Scale to sphere, use Euclidean distance
        X = bsxfun(@minus, X, mean(X, 1));
        X = bsxfun(@times, X, 1.0./sqrt(sum(X.*X, 2)));
        D = squareform(pdist(X));
    elseif type == 2
        %Scale to sphere, use correlation
        X = bsxfun(@minus, X, mean(X, 1));
        X = bsxfun(@times, X, 1.0./sqrt(sum(X.*X, 2)));
        D = X*X';
    else
        disp('Error: Unknown distance type');
        X = 0;
        D = 0;
    end
end
