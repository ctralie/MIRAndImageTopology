%Page 12 of the paper "The Ring of Algebraic Functions on Persistence Bar
%Codes"
function [ fTDA ] = getAlgebraicFunctionsOnBars( AllPDs )
    N = length(AllPDs)*length(AllPDs{1});
    fTDA = zeros(N, 3*4);
    index = 1;
    for ii = 1:length(AllPDs)
        for jj = 1:length(AllPDs{ii})
           for kk = 1:3
              J = AllPDs{ii}{jj}{kk};
              X = J(:, 1);
              Y = J(:, 2);
              fTDA(index, (1:4) + (kk-1)*4) = ... 
                 [sum(X.*(Y-X)), ...
                  sum( (max(Y) - Y).*(Y - X) ), ...
                  sum(X.*X.*(Y-X).^4), ...
                  sum((max(Y) - Y).^2.*(Y - X).^4)];
           end
           index = index + 1;
        end
    end
end