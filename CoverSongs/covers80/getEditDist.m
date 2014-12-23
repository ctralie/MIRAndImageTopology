function [ d, D ] = getEditDist( s1, s2 )
    N = length(s1);
    M = length(s2);
    D = zeros(N, M);
    D(:, 1) = 0:N-1;
    D(1, :) = 0:M-1;
    for ii = 2:N
        for jj = 2:M
            D(ii, jj) = min([D(ii-1, jj)+1, D(ii, jj-1)+1, ...
                D(ii-1, jj-1) + 2*(abs(s1(ii)-s2(jj)) > 0)]);
        end
    end
    d = D(N, M);
end