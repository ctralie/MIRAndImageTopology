foldername = 'FaceDataIR/4_30_chris_ir_depth_30';

getFrameFnIR = @(ii) getFrameFnFolder(foldername, ii, 1);
getFrameFnDepth = @(ii) getFrameFnFolder(foldername, ii, 2);

%Try to estimate two points on the cheek, and assume they don't move too
%much
Keypoints = squeeze(getFaceKeypoints(getFrameFnIR, 0, 1));
Keypoints = [Keypoints; 0.5*(Keypoints(20, :) + Keypoints(32, :)); 0.5*(Keypoints(29, :) + Keypoints(38, :))];
thisFrame = getFrameFnIR(1);
X = Keypoints;
imagesc(thisFrame);
hold on;
plot(X(1:end-2, 1), X(1:end-2, 2), 'g.');
scatter(X(end-1:end, 1), X(end-1:end, 2), 20, 'r', 'fill');

