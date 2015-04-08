%
% Sparse Modeling of Intrinsic Correspondences. Computer Graphics Forum '13
% 
addpath(genpath('ShapeLAB'));
addpath('../ImageWarp');

list1 = '../covers80/covers32k/list1.list';
list2 = '../covers80/covers32k/list2.list';
files1 = textread(list1, '%s\n');
files2 = textread(list2, '%s\n');

dim = 100;
XYExtent = 1;
BeatsPerWin = 8;
beatDownsample = 2;

%Setup beat shape meshes
Ds1 = getBeatSyncDistanceMatricesSlow( files1{76}, dim, BeatsPerWin, beatDownsample );
Ds2 = getBeatSyncDistanceMatricesSlow( files2{76}, dim, BeatsPerWin, beatDownsample );

D1 = reshape(Ds1(1, :), dim, dim);
D2 = reshape(Ds2(2, :), dim, dim);
grid = linspace(-XYExtent, XYExtent, dim);
[X1, Y1] = meshgrid(grid, grid);
[f, v, c] = surf2patch(X1, Y1, D1);
shape1.TRIV = f;
shape1.X = v(:, 1);
shape1.Y = v(:, 2);
shape1.Z = v(:, 3);
shape1.parts = zeros(dim*dim, 1);
shape1.parts(abs(shape1.X - shape1.Y) < XYExtent/4) = 1;%Make the first component the diagonal
shape1.parts(shape1.X == XYExtent & shape1.Y == 0) = 2;%Second component is upper right corner
shape1.parts(shape1.X == 0 & shape1.Y == XYExtent) = 3;%Third component is lower left corner

shape2 = shape1;
shape2.Z = D2(:);
s = cell(1, 2);
s{1} = shape1;
s{2} = shape2;

nV = 20; %num eigenfunctions
numFeatureSamples = 100;

for k = 1:length(s)
    s{k}.funcs = {};
    [s{k}.evecs, s{k}.evals, s{k}.areas, s{k}.W] = calcLaplacianBasis(s{k}, nV);
    s{k}.basis = sqrt(s{k}.areas) * s{k}.evecs;
    
    indF = s{k}.parts; 
    s{k}.funcs = {s{k}.funcs{:}, indF};
end  


[C, O] = calcCFromFuncsAndStructure(s{1}, s{2}, s{1}.funcs, s{2}.funcs, 'basis1', s{1}.basis, 'basis2', s{2}.basis, 'debug',0);
[shape1ToShape2, shape2ToShape1, C] = calcP2PFromC(s{1}, s{2}, C, s{1}.evecs, s{2}.evecs, 'debug', 0,'numRefinements', 30);
D = C'*C;

drawPartsOnShape(s{1}, s{1}.parts, 'strip', 0);light;lighting flat;