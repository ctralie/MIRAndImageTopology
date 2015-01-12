function [ d, D ] = getDTWDist( Is1, Is2, wassexp )
    N = length(Is1)+1;
    M = length(Is2)+1;
    D = zeros(N, M);
    for ii = 2:N
        for jj = 2:M
            dij = getWassersteinDist(Is1{ii}, Is2{jj}, wassexp);
            D(ii, jj) = min([D(ii-1, jj)+dij, D(ii, jj-1)+dij, ...
                D(ii-1, jj-1) + dij]);
        end
    end
    d = D(N, M);
end