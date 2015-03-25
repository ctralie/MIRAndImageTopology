function [ d, D ] = getDTWDist( Is1, Is2, normtype )
    if nargin < 3
        normtype = 2;
    end
    N = length(Is1)+1;
    M = length(Is2)+1;
    D = zeros(N, M);
    for ii = 2:N
        for jj = 2:M
            %dij = getWassersteinDist(Is1{ii}, Is2{jj}, normtype);
            I1 = Is1{ii-1};
            I2 = Is2{jj-1};
            %Take the norm between the top two bars (zeropad if necessary)
            %Assumes that these are already sorted in descending order
            %by persistence
            if (size(I1, 1) > 2)
                I1 = I1(1:2, :);
            else
                I1 = [I1; zeros(2 - size(I1, 1), 2)];
            end
            if (size(I2, 1) > 2)
                I2 = I2(1:2, :);
            else
                I2 = [I2; zeros(2 - size(I2, 1), 2)];
            end
            dij = (sum((I1(:) - I2(:)).^normtype))^(1/normtype);
            D(ii, jj) = min([D(ii-1, jj)+dij, D(ii, jj-1)+dij, ...
                D(ii-1, jj-1) + dij]);
        end
    end
    d = D(N, M);
end