addpath('../VideoPeriodicities/VideoMagnification');

OUTPUTREGION = 1;
DODERIV = 0;
FlipY = 1;
pdim = 2;
DelayWindow = 10;

obj = VideoReader('fanmedium.avi');
getFrameFn = @(ii) getFrameFnVideoReader(obj, ii, FlipY);
V = getVideo('fanmedium.avi');

[I, newDims] = getPixelGridEmbeddingInMemory( V, pdim, DelayWindow, DODERIV );

IM = reshape(I, [size(I, 1) newDims(:)' 3]);
if DODERIV
    IM = IM - min(IM(:));
    IM = uint8((255/max(IM(:)))*IM);
else
    IM = uint8(IM);
end

if OUTPUTREGION
    writerObj = VideoWriter('fanregion.avi');
    open(writerObj);
    for ii = 1:size(IM, 1)
        writeVideo(writerObj, squeeze(IM(ii, :, :, :)));
    end
    close(writerObj);
end

dotI= dot(I, I, 2);
D = bsxfun(@plus, dotI, dotI') - 2*(I*I');
D(1:size(D, 1)+1:end) = 0; %Need this for numerical precision
[Y, latent] = cmdscale(D);

theta = atan2(Y(:, 2), Y(:, 1));
[~, idx] = sort(theta);

viewVideoReordered(getFrameFn, Y, idx);