%Parameters from SLURM: songIdx, dim, BeatsPerWin
addpath('../SequenceAlignment');
addpath('../ImageWarp');
addpath(genpath('spams-matlab'));
list2 = '../covers80/covers32k/list2.list';
files2 = textread(list2, '%s\n');

lambdas = [100, 1000, 10000];

alphas = cell(80, length(lambdas));
DFit = cell(80, length(lambdas));
DAlphaAlign = zeros(80, length(lambdas));

X = getBeatSyncDistanceMatricesSlow(files2{songIdx}, dim, BeatsPerWin, 2);
X = X';
fprintf(1, 'Doing %s...\n', files2{songIdx});

param.numThreads = 4;
param.iter = 1000;
param.mode = 2;
param.posAlpha = 1;
param.posD = 1;
param.pos = 1;

for ii = 1:80
    fprintf('Doing %s with dict %i...\n', files2{songIdx}, ii);
    Dict = load(sprintf('SelfDicts%i/%i.mat', dim, ii));
    Dict = Dict.D;
    param.K = size(Dict, 2);
    
    for kk = 1:length(lambdas)
        param.lambda = lambdas(kk);
        tic
        alphas{ii, kk} = mexLasso(X, Dict, param);
        toc
        DFit{ii, kk} = 0.5*sum((X-Dict*alphas{ii, kk}).^2, 1);
        M = full(double(alphas{ii, kk} > 0));
        DAlphaAlign(ii, kk) = swalignimp(M)/sum(size(M));
    end
end

save(sprintf('SelfDicts%i/Results%i_2.mat', dim, songIdx), 'lambdas', 'alphas', 'DFit', 'DAlphaAlign');