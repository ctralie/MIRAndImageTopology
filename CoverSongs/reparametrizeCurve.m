function [ Y, idx ] = reparametrizeCurve( X, t )
    if size(X, 1) == 1
        Y = X;
        return;
    end
    N = size(X, 1);
    dim = size(X, 2);
    Y = zeros(length(t), dim);
    torig = linspace(0, 1, N);
    idx = zeros(length(t), 1);
    dt = torig(2) - torig(1);
    for ii = 1:length(t)
        i2 = find(torig > t(ii), 1);
        if (isempty(i2)) %The end has been reached
            Y(end, :) = X(end, :);
            idx(ii) = size(X, 1);
            continue;
        end
        i1 = i2 - 1;
        Y(ii, :) = ((t(ii) - torig(i1))*X(i1, :) + (torig(i2) - t(ii))*X(i2, :))/dt;
        idx(ii) = i1;
    end
end

