function [ d, D ] = getEditDist( s1, s2, type )
    N = length(s1)+1;
    M = length(s2)+1;
    
    if nargin < 3
        type = 2;
    end
    
    if type == 1
        %Levenshtein Distance
        D = zeros(N, M);
        D(:, 1) = 0:N-1;
        D(1, :) = 0:M-1;
        for ii = 2:N
            for jj = 2:M
                D(ii, jj) = min([D(ii-1, jj)+1, D(ii, jj-1)+1, ...
                    D(ii-1, jj-1) + 2*(abs(s1(ii-1)-s2(jj-1)) > 0)]);
            end
        end
        d = D(N, M);
    elseif type == 2
        %Needleman-Wunsch Distance
        D = zeros(N, M);%Don't penalize for gaps at the beginning
        for ii = 2:N
            for jj = 2:M
                eq = 2;%Match score
                if (abs(s1(ii-1)-s2(jj-1)) > 0)
                    eq = -3;%Mismatch penalty
                end
                eq = D(ii-1,jj-1) + eq;
                gapi = D(ii-1, jj) - 2;
                gapj = D(ii,  jj-1) - 2;
                D(ii, jj) = max([eq, gapi, gapj]);
            end
        end
        d = D(N, M);
    end
end