addpath('../VideoPeriodicities/VideoMagnification');

OUTPUTREGION = 0;
DODERIV = 0;
FlipY = 0;
pdim = 1;
DelayWindow = 30;
NPCs = 12;

%filename = 'standingwave1modeaa.ogg';
%filename = 'fanmedium_small.avi';
%obj = VideoReader(filename);
%getFrameFn = @(ii) getFrameFnVideoReader(obj, ii, FlipY);
%V = getVideo(filename);

foldername = 'standingwave1modesmallaa';
V = getVideoFromFiles(foldername);

%V = getVideo('face.avi', [100, 100]);
%foldername = 'face';

[I, newDims] = getPixelGridEmbeddingInMemory( V, pdim, DelayWindow, DODERIV );

if OUTPUTREGION && DelayWindow == 1
    IM = reshape(I, [size(I, 1) newDims(:)' 3]);
    if DODERIV
        IM = IM - min(IM(:));
        IM = uint8((255/max(IM(:)))*IM);
    else
        IM = uint8(IM);
    end
    writerObj = VideoWriter('fanregion.avi');
    open(writerObj);
    for ii = 1:size(IM, 1)
        writeVideo(writerObj, squeeze(IM(ii, :, :, :)));
    end
    close(writerObj);
end

disp('Doing PCA...');
tic;
I = bsxfun(@minus, I, mean(I, 1));
I = bsxfun(@times, 1./sqrt(sum(I.^2, 2)), I);
dotI= dot(I, I, 2);
D = bsxfun(@plus, dotI, dotI') - 2*(I*I');
%Need this for numerical precision
D(D < 0) = 0;
D = D + D';
D(1:size(D, 1)+1:end) = 0;
[Y, latent] = cmdscale(D);

%Compute principal components
[~, S, PCs] = svds(I, NPCs);
toc;
PCs = reshape(PCs, [DelayWindow, size(V{1}), size(PCs, 2)]);
PCs = shiftdim(PCs, 1);
NonzeroCanvas = abs(PCs) > 0.05;

%TODO: Amplify first two principal components
outputPCs( PCs, foldername );

close all;
idx = doTSP(D, 1);
%idx = 1:size(D, 1);

viewVideoReordered(V, Y, idx);