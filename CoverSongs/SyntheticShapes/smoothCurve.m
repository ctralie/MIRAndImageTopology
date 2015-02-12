function [ Y ] = smoothCurve( X, Fac )
    NPoints = size(X, 1);
    dim = size(X, 2);
    idx = 1:NPoints;
    idxx = linspace(1, NPoints, NPoints*Fac);
    Y = zeros(NPoints*Fac, dim);
    for ii = 1:dim
        Y(:, ii) = spline(idx, X(:, ii), idxx);
        Y(:, ii) = smooth(Y(:, ii), Fac*2);
    end
end