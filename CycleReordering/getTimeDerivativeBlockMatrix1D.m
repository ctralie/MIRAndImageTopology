function [A, NTap] = getTimeDerivativeBlockMatrix1D( NSamples, window  )
    dw = floor(window/2);
    t = -dw:dw;
    sigma = 0.4*dw;
    xgaussf = t.*exp(-t.*t ./ (2*sigma^2));
    %Normalize by L1 norm to control for length of window
    xgaussf = xgaussf/sum(abs(xgaussf)); 
    NTap = length(xgaussf);
    K = length(xgaussf);
    NWin = NSamples-K+1;
    B = repmat(xgaussf(:)', [NWin 1]);
    fprintf(1, '%i x %i\n', NWin, NSamples);
    A = spdiags(B, 0:2*dw, NWin, NSamples);
end

