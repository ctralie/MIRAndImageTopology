%Spatial average down onto a smaller grid
function [I, newDims] = getPixelGridEmbeddingInMemory( V, pdim, DelayWindow, DODERIV )
    N = length(V);
    dims = size(V{1});    
    newDims = ceil(dims(1:2)/pdim);
    I = zeros(N, prod(newDims)*3);
    tic;
    for ii = 1:N
        thisFrame = imresize(V{ii}, newDims);
        I(ii, :) = thisFrame(:)';
    end
    toc;
    if DODERIV
        tic;
        I = getSmoothedDerivative(I, DelayWindow);
        toc;
    end
    if DelayWindow > 1
        I = getDelayEmbedding(I, DelayWindow);
    end
end

