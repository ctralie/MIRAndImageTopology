addpath(genpath('../EMD'));
addpath('../ImageWarp');
list1 = '../covers80/covers32k/list1.list';
list2 = '../covers80/covers32k/list2.list';

files1 = textread(list1, '%s\n');
files2 = textread(list2, '%s\n');
N = length(files1);

%Patch Match Params
NIters = 3;
Alpha = 0.3;
K = 4;

dirname = sprintf('AllCrossSimilarities%i', BeatsPerWin);
if ~exist(dirname)
    mkdir(dirname);
end

fprintf(1, 'Doing %s\n', files2{songIdx});
%Get beat sync distance matrices and wavelet distance matrices for this
%song
[DEmd, DL2, Norms] = getBeatSyncEMDWavelets(files2{songIdx}, dim, BeatsPerWin, 2);
DEmd = single(full(DEmd)); DL2 = single(DL2);
MsEMD = cell(1, N);
MsL2 = cell(1, N);

for jj = 1:N
    %Get beat sync distance matrices and wavelet matrices for the other
    %song
    [DsOrigEmd, DsOrigL2] = getBeatSyncEMDWavelets(files1{jj}, dim, BeatsPerWin, 2);
    DsOrigEmd = single(full(DsOrigEmd));
    DsOrigL2 = single(DsOrigL2);    
    tic
    fprintf(1, 'Doing EMD patch match for %s vs %s...\n', files1{jj}, files2{songIdx});
    CSM = pdist2(DsOrigEmd, DEmd, 'cityblock'); %TODO: Speed this up
    CSM(isnan(CSM)) = inf;
    M = patchMatch1DIMPMatlab(CSM, NIters, K, Alpha);
    MsEMD{jj} = M;        
    toc
    
    tic
    fprintf(1, 'Doing L2 patch match for %s vs %s...\n', files1{jj}, files2{songIdx});
    CSM = bsxfun(@plus, dot(DsOrigL2, DsOrigL2, 2), dot(DL2, DL2, 2)') - 2*(DsOrigL2*DL2');
    CSM = sqrt(CSM);    
    M = patchMatch1DIMPMatlab(CSM, NIters, K, Alpha);
    MsL2{jj} = M;    
    toc

end
save(sprintf('%s/%i.mat', dirname, songIdx), 'MsEMD', 'MsL2');

