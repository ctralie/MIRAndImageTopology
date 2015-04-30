function [Y] = getSmoothedDerivative( X, window )
    dw = round(window/2);
    t = -dw:dw;
    sigma = 0.4*dw;
    xgaussf = -t.*exp(-t.*t ./ (2*sigma^2));
    Y = conv2(X', xgaussf, 'valid')';
end

