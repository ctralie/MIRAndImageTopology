obj = VideoReader('guitar.avi');
N = obj.NumberOfFrames;
thisFrame = read(obj, 1);

NSamples = 100; %Number of samples on the string
t = linspace(0, 1, NSamples);
t = repmat(t, [2, 1]);
% 350hz F
% u = [97; 42];
% v = [163; 432];
% 82.4hz E
u = [19; 49];
v = [91; 432];

X = repmat(u, [1 NSamples]) + t.*repmat(v - u, [1 NSamples]);
X = X';

dims = [size(thisFrame, 1), size(thisFrame, 2)];
[I, J] = meshgrid(1:dims(2), 1:dims(1));
T = delaunayTriangulation(X);
[~, dists] = T.nearestNeighbor([J(:) I(:)]);
dists = reshape(dists, [dims(1), dims(2)]);
thisFrame = reshape(thisFrame, [dims(1)*dims(2), 3]);
thisFrame(dists < 3, 2) = 255;
ind = 1:size(thisFrame, 1);
ind = ind(dists < 3);
thisFrame = reshape(thisFrame, [dims(1), dims(2), 3]);
%imagesc(thisFrame);

ind = repmat(ind(:)', [N, 1]);
[region, R, theta] = getPixelSubsetEmbedding( 'guitar.mp4', ind, 30, 1, 1 );