function [ X ] = getBeatSyncChromaDelay( sprefix, M, rotate )
    if nargin < 3
        rotate = 0;
    end
    C = getBeatSyncChromaMatrix(sprefix, 1, 1, rotate);
    NChroma = size(C, 2);
    N = size(C, 1) - M + 1;
    X = zeros(N, NChroma*M);
    for ii = 1:N
        thisX = C(ii:ii+M-1, :);
        X(ii, :) = thisX(:)';
    end
end

