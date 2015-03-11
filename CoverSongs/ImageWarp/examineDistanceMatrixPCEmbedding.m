addpath(genpath('spams-matlab'));
list1 = '../covers80/covers32k/list1.list';
list2 = '../covers80/covers32k/list2.list';
files1 = textread(list1, '%s\n');
files2 = textread(list2, '%s\n');

dim = 200*2;
windim = 20;
tic
D = getBeatSyncDistanceMatricesSlow(files2{41}, dim, 8);
toc

%Set up position images
[I, J] = meshgrid(linspace(0, 1, windim), linspace(0, 1, windim));
X = im2col(reshape(D(1, :), dim, dim), [windim windim], 'sliding');
XPos = 1:size(X, 2);
XPosv = floor((XPos-1)/(dim-windim+1))+1;
XPosu = XPos - (XPosv-1)*(dim-windim+1);
XPosu = XPosu/dim;
XPosv = XPosv/dim;
PosIm = zeros(windim*windim, size(X, 2));
STDev = 0.05;
for ii = 1:size(PosIm, 2)
    Im = exp(-( (I-XPosu(ii)).^2 + (J-XPosv(ii)).^2 )/(STDev*STDev));
    Im = 0.1*(Im + Im');
    PosIm(:, ii) = Im(:);
end

for ii = 1:size(D, 1)
    D1 = reshape(D(ii, :), dim, dim);
    X = im2col(D1, [windim windim], 'sliding');
    X = [X; PosIm];
    
    GridSize = 5;
    param.K = GridSize*GridSize;
    param.numThreads = 4;
    param.lambda = 0.15;
    param.iter = 1000;
    Dict = nnsc(X, param);
    alphas = mexLasso(X, Dict, param);
    for jj = 1:size(Dict, 2)
        a = mod((jj-1), GridSize)+1;
        b = floor((jj-1)/GridSize);
        subplot(GridSize, GridSize*3, GridSize*2 + a + b*(GridSize*3));
        imagesc(reshape(Dict(:, jj), windim, windim*2));
        axis off;
        axis equal;
    end
    
    %[~, Y, lambda] = pca(full(alphas'));
    [~, Y, lambdas] = pca(X');
    
    gridLocs = repmat(1:GridSize, [GridSize, 1]);
    deltaRow = GridSize*3*(0:GridSize-1);
    gridLocs = bsxfun(@plus, gridLocs, deltaRow(:));
    subplot(GridSize, GridSize*3, gridLocs);
    imagesc(D1);
    colormap('jet');
    axis equal;
    axis off;
    title(sprintf('Beat %i', ii));
    
    gridLocs = gridLocs + GridSize;
    subplot(GridSize, GridSize*3, [gridLocs(1) gridLocs(end)]);
    idx = randperm(size(Y, 1), 1000);
    plot3(Y(:, 1), Y(:, 2), Y(:, 3), '.');
    axis equal;
    title(sprintf('Variance Explained: %g', sum(lambda(1:3))/sum(lambda)));
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 45 15]); 
    print('-dpng', '-r100', sprintf('%i.png', ii));
end