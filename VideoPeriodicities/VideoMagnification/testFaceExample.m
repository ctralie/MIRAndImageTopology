filename = 'MeMovingLong.mov';
pdim = 5;
FlipY = 1;
Keypoints = getFaceKeypoints(filename, FlipY);
obj = VideoReader(filename);
thisFrame = read(obj, 1);
dims = size(thisFrame);
KeypointsIdx = 11:14;%Nose keypoints only
PatchRegions = getKeypointPatches( Keypoints, dims(1:2), KeypointsIdx, pdim );

DelayWindow = 30;
[region, R, theta] = getPixelSubsetEmbedding( filename, PatchRegions, DelayWindow, 1, 1, 0, FlipY );

D = squareform(pdist(R));
dintervals = [];
for ii = 1:size(D, 1)
    [~, idx] = findpeaks(D(ii, :));
    dintervals = [dintervals idx(2:end) - idx(1:end-1)];
end
dintervals = dintervals/30;
hist(dintervals, 100);