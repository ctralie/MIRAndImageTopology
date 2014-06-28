%Get the histogram due to one sub-component of a block (Equation 6 in the
%paper)
function [ hist ] = getHOG3DHistogram( ii, jj, kk, FramesMat, P, thresh )
    XLeft = FramesMat(ii:ii+1, jj, kk:kk+1);
    XRight = FramesMat(ii:ii+1, jj+1, kk:kk+1);
    YBottom = FramesMat(ii, jj:jj+1, kk:kk+1);
    YTop = FramesMat(ii+1, jj:jj+1, kk:kk+1);
    ZBack = FramesMat(ii:ii+1, jj:jj+1, kk);
    ZFront = FramesMat(ii:ii+1, jj:jj+1, kk+1);
    grad = zeros(3, 1);
    grad(1) = mean(XRight(:)) - mean(XLeft(:));
    grad(2) = mean(YTop(:)) - mean(YBottom(:));
    grad(3) = mean(ZFront(:)) - mean(ZBack(:));
    hist = max(P*grad - thresh, 0);%Shrink based on near bin threshold 
end