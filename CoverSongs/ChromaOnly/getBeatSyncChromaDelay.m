function [ X, C ] = getBeatSyncChromaDelay( sprefix, M, rotate, C )
    if nargin < 3
        rotate = 0;
    end
    if nargin < 4
        C = getBeatSyncChromaMatrixEllis(sprefix);
        %C = getBeatSyncChromaMatrix(sprefix, 1, 1);
    end
    if rotate > 0
        C = circshift(C, rotate, 2);
    end
    NChroma = size(C, 2);
    N = size(C, 1) - M + 1;
    X = zeros(N, NChroma*M);
    for ii = 1:N
        thisX = C(ii:ii+M-1, :);
        X(ii, :) = thisX(:)';
    end
end

