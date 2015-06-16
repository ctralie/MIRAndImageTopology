addpath('../VideoPeriodicities/VideoMagnification');
obj = VideoReader('fanreorderedatan.avi');

FlipY = 1;
pdim = 10;
DelayWindow = 15;

getFrameFn = @(ii) getFrameFnVideoReader(obj, ii, FlipY);
I = getFrameFn(1);
dims = size(I);

NW = ceil(dims(2)/pdim);
NH = ceil(dims(1)/pdim);

PatchRegions = getFixedGridPatches(getFrameFn, pdim, pdim);
fprintf(1, 'There are %i patch regions, each %i x %i\n', length(PatchRegions), pdim, pdim);

[region, R, theta, Y] = getPixelSubsetEmbedding( getFrameFn, PatchRegions, DelayWindow, 1, 1, 1 );
IM = reshape(region, [size(region, 1), NH, NW, 3]);

for ii = 1:size(IM, 1)
    imagesc(squeeze(IM(ii, :, :, 1)));
    pause(0.3);
end


K = 3;
dotR = dot(R, R, 2);
DMetric = bsxfun(@plus, dotR, dotR') - 2*(R*R'); 
[NNF, NNFD, A] = getKNN(DMetric, K);
D = sum(A, 2);
L = spdiags(D, 0, speye(size(A, 1)))-A;

[E, V] = eigs(L, 2, 'sm');
fiedler = E(:, end-1); %Fiedler vector