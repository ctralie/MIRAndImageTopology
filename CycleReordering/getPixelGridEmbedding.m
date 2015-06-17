%Spatial average down onto a smaller grid
function [I, newDims] = getPixelGridEmbedding( getFrameFn, pdim, DelayWindow )
    N = getFrameFn(-1);
    thisFrame = getFrameFn(1);
    dims = size(thisFrame);    
    newDims = ceil(dims(1:2)/pdim);
    I = zeros(N, prod(newDims)*3);
    for ii = 1:N
        thisFrame = imresize(getFrameFn(ii), newDims);
        I(ii, :) = thisFrame(:)';
    end
    
end

