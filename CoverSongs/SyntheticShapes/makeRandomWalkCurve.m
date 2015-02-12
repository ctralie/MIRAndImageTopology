function [X] = makeRandomWalkCurve( res, NPoints, dim )
    %Enumerate all neighbors in hypercube
    Neighbs = zeros(3^dim, dim);
    Neighbs(1, :) = -1*ones(1, dim);
    idx = 2;
    for ii = 2:3^dim
        N = Neighbs(idx-1, :);
        N(1) = N(1) + 1;
        for kk = 1:dim
            if N(kk) > 1
                N(kk) = -1;
                N(kk+1) = N(kk+1) + 1;
            end
        end
        Neighbs(idx, :) = N;
        idx = idx + 1;
    end
    Neighbs = Neighbs(sum(abs(Neighbs), 2) > 0, :);

    %Pick a random starting point
    X = zeros(NPoints, dim);
    X(1, :) = randi(res, [1 dim]);    
    
    for ii = 2:NPoints
        prev = X(ii-1, :);
        N = repmat(prev, [size(Neighbs, 1), 1]) + Neighbs;
        N = N( N(:, 1) > 0 & N(:, 1) <= res & N(:, 2) > 0 & N(:, 2) <= res, :);
        X(ii, :) = N(randi(size(N, 1)), :);
    end
end