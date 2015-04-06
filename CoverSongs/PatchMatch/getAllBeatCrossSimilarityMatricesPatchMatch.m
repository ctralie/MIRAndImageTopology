addpath('../ImageWarp');
list1 = '../covers80/covers32k/list1.list';
list2 = '../covers80/covers32k/list2.list';

files1 = textread(list1, '%s\n');
files2 = textread(list2, '%s\n');
N = length(files1);

%Patch match parameters
NNFunction = @(x, y, dim) pdist2(x(:)', y(:)'); %Test with L2 (dim is dummy variable in this case)
NIters = 5;
K = 3;

dim = 400;
BeatsPerWin = 8;
dirname = sprintf('AllCrossSimilarities%i', BeatsPerWin);
if ~exist(dirname)
    mkdir(dirname);
end

DsOrig = cell(1, N);
parfor ii = 1:N
    fprintf(1, 'Getting distance matrices for %s\n', files1{ii});
    DsOrig{ii} = single(getBeatSyncDistanceMatricesSlow(files1{ii}, dim, BeatsPerWin));
end

AllMs = cell(N, N);
TotalQueries = zeros(N, N);

for ii = 1:N
    fprintf(1, 'Doing %i of %i\n', ii, N);
    tic
    D = single(getBeatSyncDistanceMatricesSlow(files2{ii}, dim, BeatsPerWin));
    thisMs = cell(1, N);
    thisQueries = zeros(1, N);
    parfor jj = 1:N
        [ M, ~, TotalQueried ] = patchMatch1DMatlab( '', '', dim, BeatsPerWin, NNFunction, NIters, K, DsOrig{jj}, D );
        thisMs{jj} = sparse(M);
        thisQueries(jj) = TotalQueried;
        fprintf(1, '.');
    end
    AllMs(ii, :) = thisMs;
    TotalQueries(ii, :) = thisQueries;
    fprintf(1, '\n');
    toc
    save(sprintf('AllDissimilarities%i/%i.mat', BeatsPerWin, ii), 'Ms');
end


