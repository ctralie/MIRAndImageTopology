addpath('../VideoPeriodicities/VideoMagnification');
obj = VideoReader('../VideoPeriodicities/VideoMagnification/guitarAmplifiedE.avi');
N = obj.NumberOfFrames;
thisFrame = read(obj, 1);
dims = [size(thisFrame, 1), size(thisFrame, 2)];
getFrameFn = @(ii) getFrameFnVideoReader(obj, ii);
FramesPerSec = 600;

NSamples = 100; %Number of samples on the string
t = linspace(0, 1, NSamples);
t = repmat(t, [2, 1]);
% 350hz F
% u = [97; 42];
% v = [163; 432];
% 82.4hz E
% u = [19; 49];
% v = [91; 432];
% u = [34; 49];
% v = [106; 431];

%The range of the whole string
u = [21; 62];
v = [91; 431];

%The second fret
dN = 3;
%38, 149 further down on string, 81, 383 towards second fret
pixeli = 81-dN:81+dN;
pixelj = 383-dN:383+dN;
[ind2i, ind2j] = meshgrid(pixeli, pixelj);
ind2 = sub2ind(dims, ind2i(:), ind2j(:));

X = repmat(u, [1 NSamples]) + t.*repmat(v - u, [1 NSamples]);
X = X';
[J, I] = meshgrid(1:dims(2), 1:dims(1));
T = delaunayTriangulation(X);
[~, dists] = T.nearestNeighbor([I(:) J(:)]);
dists = reshape(dists, [dims(1), dims(2)]);
thisFrame = reshape(thisFrame, [dims(1)*dims(2), 3]);
ind = 1:size(thisFrame, 1);
ind = ind(dists < 3);
IInd = I(ind(:));
JInd = J(ind(:));
thisFrame(ind, 2) = 255;
thisFrame = reshape(thisFrame, [dims(1), dims(2), 3]);

ind = ind2;
[region, R, theta, Y] = getPixelSubsetEmbedding( getFrameFn, {repmat(ind, [N, 1])}, 5, 0, 0, 0 );
figure(1);
subplot(1, 2, 1);
imagesc(thisFrame);
subplot(1, 2, 2);
plot3(Y(:, 1), Y(:, 2), Y(:, 3), '.');

%Uncomment to plot 2D and 3D PCA on different types of embeddings for
%the string example
% [~, Y] = pca(R);
% subplot(2, 2, 1);
% plot(Y(:, 1), Y(:, 2), '.');
% title('Full Embedding 2D PCA');
% subplot(2, 2, 2);
% plot3(Y(:, 1), Y(:, 2), Y(:, 3), '.');
% title('Full Embedding 3D PCA');
% 
% [region, R, theta] = getPixelSubsetEmbedding( getFrameFn, {ind}, 10, 1, 1, 0 );
% [~, Y] = pca(R);
% subplot(2, 2, 3);
% plot(Y(:, 1), Y(:, 2), '.');
% title('Averaged Embedding 2D PCA');
% subplot(2, 2, 4);
% plot3(Y(:, 1), Y(:, 2), Y(:, 3), '.');
% title('Averaged Embedding 3D PCA');

[~, idx] = sort(theta);
V = getVideo('../VideoPeriodicities/VideoMagnification/guitar.avi');
dims = size(V{1});
for ii = 1:length(V)
    V{ii} = V{ii}(:);
end
V = cell2mat(V);
V = V';
V = reshape(V, [size(V, 1) dims]);
VR = V(idx, :, :, :);

sorig = V(:, pixeli, pixelj, :);
sreorder = squeeze(VR(:, pixeli, pixelj, :));
sorig = squeeze(mean(mean(sorig, 2), 3));
sreorder = squeeze(mean(mean(sreorder, 2), 3));

%%Uncomment to take average of all pixels
% sorig = zeros(size(V, 1), length(IInd), 3);
% sreorder = zeros(size(VR, 1), length(IInd), 3);
% for ii = 1:length(IInd)
%     sorig(:, ii, :) = squeeze(V(:, IInd(ii), JInd(ii), :));
%     sreorder(:, ii, :) = squeeze(VR(:, IInd(ii), JInd(ii), :));
% end
% sorig = bsxfun(@minus, min(sorig, [], 1), sorig);
% sreorder = bsxfun(@minus, min(sreorder, [], 1), sreorder);
% 
% sorig = squeeze(mean(sorig, 2));
% sreorder = squeeze(mean(sreorder, 2));

figure(2);
colors = {'r', 'g', 'b'};
colorsn = {'Red', 'Green', 'Blue'};
for cc = 1:3
    subplot(3, 3, cc);
    plot(sorig(:, cc), colors{cc});
    title(sprintf('Original %s', colorsn{cc}));
    subplot(3, 3, cc+3);
    plot(sreorder(:, cc), colors{cc});
    title(sprintf('Reordered %s', colorsn{cc}));
end

%Color chosen rectangular patch in image
thisFrame = getFrameFn(1);
thisFrame(pixeli, pixelj, 2) = 255;
subplot(3, 3, 7);
imagesc(thisFrame);
axis off;

%Look at embedding of just this rectangular patch
getFrameFn2 = @(ii) getFrameFnMemory(V, N, ii);
[~, RSquare, ~, Y] = getPixelSubsetEmbedding( getFrameFn2, {repmat(ind2, [N, 1])}, 10, 0, 0, 0 );
subplot(3, 3, 8);
plot3(Y(:, 1), Y(:, 2), Y(:, 3));
title('Time Ordering');
subplot(3, 3, 9);
plot3(Y(idx, 1), Y(idx, 2), Y(idx, 3));
title('Reordered');