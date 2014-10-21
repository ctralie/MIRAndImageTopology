function [ ret ] = getMeanDiff( X, N1 )
    ret = norm(mean(X(1:N1, :)) - mean(X(N1+1:end, :)));
end

