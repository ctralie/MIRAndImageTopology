obj = VideoReader('MeMovingLong.mov');
FlipY = 1;
getFrameFn = @(ii) getFrameFnVideoReader(obj, ii, FlipY);
pdim = 5;
FlipY = 1;
Keypoints = getFaceKeypoints(getFrameFn);
thisFrame = getFrameFn(1);
dims = size(thisFrame);
KeypointsIdx = 11:14;%Nose keypoints only
PatchRegions = getKeypointPatches( Keypoints, dims(1:2), KeypointsIdx, pdim );

DelayWindow = 30;
[region, R, theta] = getPixelSubsetEmbedding( getFrameFn, PatchRegions, DelayWindow, 1, 1, 0 );

D = squareform(pdist(R));
dintervals = [];
for ii = 1:size(D, 1)
    [~, idx] = findpeaks(D(ii, :));
    dintervals = [dintervals idx(2:end) - idx(1:end-1)];
end
dintervals = dintervals/30;
hist(dintervals, 100);