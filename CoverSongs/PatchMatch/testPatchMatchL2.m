list1 = '../covers80/covers32k/list1.list';
list2 = '../covers80/covers32k/list2.list';
files1 = textread(list1, '%s\n');
files2 = textread(list2, '%s\n');
addpath('../EMD');
BeatsPerWin = 8;
dim = 400;
beatDownsample = 2;

NNFunction = @(x, y, dim) pdist2(x(:)', y(:)'); %Test with L2 (dim is dummy variable in this case)

idx1 = 76;
idx2 = 76;
fprintf(1, 'Testing %s verus %s...\n', files1{idx1}, files2{idx2});
disp('Getting similarity matrices 1...');
[Ds1, Ds1L2] = getBeatSyncEMDWavelets(files2{idx1}, dim, BeatsPerWin);
Ds1 = single(Ds1); Ds1L2 = single(Ds1L2);
disp('Geting similarity matrices 2...');
[Ds2, Ds2L2] = getBeatSyncEMDWavelets(files2{idx2}, dim, BeatsPerWin);
Ds2 = single(Ds2); Ds2L2 = single(Ds2L2);

% disp('Doing patch match...');
% tic
% [NNF, Queries] = patchMatch1D(Ds1, Ds2, 5, 3, 2);
% toc
disp('Doing patch match matlab...');
tic
[NNF2, Queries2] = patchMatch1DMatlab( files1{idx1}, files2{idx2}, dim, BeatsPerWin, NNFunction, 5, 3, Ds1, Ds2 );
toc
Queries2/(size(Ds1, 1)*size(Ds2, 1))
D = zeros(size(Ds1, 1), size(Ds2, 1));
for ii = 1:size(NNF2, 1)
    for kk = 1:size(NNF2, 2)
        D(ii, NNF2(ii, kk)) = 1;
    end
end
imagesc(D);

disp('Doing brute force...');
tic
DBrute = pdist2(Ds1, Ds2);
toc
% [~, idx] = sort(DBrute, 2);
% k = quantile(DBrute(:), 0.1);
% DBruteBinary = (idx <= 10);
% subplot(1, 3, 1); imagesc(DBrute); title('Full Cross-Similarity Matrix');
% subplot(1, 3, 2); imagesc(DBruteBinary); title('10 Nearest Neighbors Brute Force');
% subplot(1, 3, 3); imagesc(DBrute < k); title('10 Percent Cutoff');
% print('-dpng', '-r100', sprintf('%i_%iBruteForce.png', idx1, idx2));