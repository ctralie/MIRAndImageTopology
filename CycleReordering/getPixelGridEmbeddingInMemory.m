%Spatial average down onto a smaller grid
function [I, newDims] = getPixelGridEmbeddingInMemory( V, pdim, DelayWindow, DODERIV )
    N = length(V);
    dims = size(V{1});
    NChannels = 1;
    if length(dims) > 2
        NChannels = dims(3);
    end
    newDims = ceil(dims(1:2)/pdim);
    I = zeros(N, prod(newDims)*NChannels);
    tic;
    for ii = 1:N
        ii
        if NChannels > 1
            thisFrame = zeros(newDims(1), newDims(2), NChannels);
            for kk = 1:NChannels
                thisFrame(:, :, kk) = imresize(squeeze(V{ii}(:, :, kk)), newDims);
            end
        else
            thisFrame = imresize(V{ii}, newDims);
        end
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

