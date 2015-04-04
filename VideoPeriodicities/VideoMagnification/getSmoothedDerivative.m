function [Y] = getSmoothedDerivative( X )
    t = -5:5;
    sigma = 3;
    xgaussf = -t.*exp(-t.*t ./ (2*sigma^2));
    Y = conv2(X', xgaussf, 'valid')';
end

