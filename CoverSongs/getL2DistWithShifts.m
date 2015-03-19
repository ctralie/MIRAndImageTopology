%It is assumed that A and B are N x N matrices with all entries >= 0
function [dist] = getL2DistWithShifts( A, B, Delta )
    N = size(A, 1);
    C = -1*ones(N, N, (2*Delta+1)^2);
    idx = 1;
    for ii = 1:2*Delta+1
        shifti = ii - Delta - 1;
        istart = max(1 - shifti, 1);
        iend = min(istart + N - 1, N);
        ki = iend - istart + 1;
        for jj = 1:2*Delta+1
            shiftj = jj - Delta - 1;
            jstart = max(1 - shiftj, 1);
            jend = min(jstart + N - 1, N);
            kj = jend - jstart + 1;
            C(1:ki, 1:kj, idx) = A(istart:iend, jstart:jend);
        end
        idx = idx + 1;
    end
    B = repmat(B, [1, 1, 2*Delta+1]);
    dist = (B - C).^2;
    dist(C == -1) = inf;
    dist = min(dist, [], 3);
    dist = sqrt(sum(dist(:)));
end