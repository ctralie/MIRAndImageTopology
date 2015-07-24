addpath('../VideoPeriodicities/VideoMagnification');
filename = '../VideoPeriodicities/VideoMagnification/guitar.avi';
DelayWindow = 10;
NPCs = 4;
DODERIV = 1;

obj = VideoReader(filename);
V = getVideo(filename);
N = obj.NumberOfFrames;
thisFrame = V{1};
dims = [size(thisFrame, 1), size(thisFrame, 2)];
getFrameFn = @(ii) getFrameFnVideoReader(obj, ii);

NSamples = 100; %Number of samples on the string
t = linspace(0, 1, NSamples);
t = repmat(t, [2, 1]);

%The range of the whole string
u = [21; 62];
v = [91; 431];
stringWidth = 3;

X = repmat(u, [1 NSamples]) + t.*repmat(v - u, [1 NSamples]);
X = X';
[J, I] = meshgrid(1:dims(2), 1:dims(1));
T = delaunayTriangulation(X);
[~, dists] = T.nearestNeighbor([I(:) J(:)]);
dists = reshape(dists, [dims(1), dims(2)]);
thisFrame = reshape(thisFrame, [dims(1)*dims(2), 3]);
ind = 1:size(thisFrame, 1);
ind = ind(dists < stringWidth);
IInd = I(ind(:));
JInd = J(ind(:));
thisFrame(ind, 2) = 255;
thisFrame = reshape(thisFrame, [dims(1), dims(2), 3]);

PatchRegions = {repmat(ind, [N, 1])};
[~, I] = getPixelSubsetEmbedding( getFrameFn, PatchRegions, DelayWindow, 0, 0, DODERIV );
disp('Doing PCA...');
tic;
I = bsxfun(@minus, I, mean(I, 1));
%I = bsxfun(@times, 1./sqrt(sum(I.^2, 2)), I);
dotI= dot(I, I, 2);
DI = bsxfun(@plus, dotI, dotI') - 2*(I*I');
%Need this for numerical precision
DI(DI < 0) = 0;
DI = DI + DI';
DI(1:size(DI, 1)+1:end) = 0;
[Y, latent] = cmdscale(DI);
%Compute principal components
[~, S, PCs] = svds(I, NPCs);
toc;

VOut = getVideo(filename);
alphas = zeros(1, NPCs);
alphas(1:2) = 0.01;
[VOut, IProj] = amplifyPCs(V, VOut, I, PCs, alphas, DelayWindow, ind);
saveVideo(VOut, 'stringamp2pc.avi');
