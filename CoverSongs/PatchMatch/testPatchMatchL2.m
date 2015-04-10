list1 = '../covers80/covers32k/list1.list';
list2 = '../covers80/covers32k/list2.list';
files1 = textread(list1, '%s\n');
files2 = textread(list2, '%s\n');
addpath('../ImageWarp');
BeatsPerWin = 8;
dim = 200;
beatDownsample = 2;

NNFunction = @(x, y, dim) pdist2(x(:)', y(:)'); %Test with L2 (dim is dummy variable in this case)

idx1 = 76;
idx2 = 76;
fprintf(1, 'Testing %s verus %s...\n', files1{idx1}, files2{idx2});
disp('Getting similarity matrices 1...');
Ds1 = getBeatSyncDistanceMatricesSlow(files1{idx1}, dim, BeatsPerWin, beatDownsample);
disp('Geting similarity matrices 2...');
Ds2 = getBeatSyncDistanceMatricesSlow(files2{idx2}, dim, BeatsPerWin, beatDownsample);

disp('Doing patch match...');
tic
[D, NNF] = patchMatch1DMatlab( files1{idx1}, files2{idx2}, dim, BeatsPerWin, NNFunction, 5, 3, Ds1, Ds2 );
toc

disp('Doing brute force...');
tic
DBrute = pdist2(Ds1, Ds2);
toc
[~, idx] = sort(DBrute, 2);
k = quantile(DBrute(:), 0.1);
DBruteBinary = (idx <= 10);
subplot(1, 3, 1); imagesc(DBrute); title('Full Cross-Similarity Matrix');
subplot(1, 3, 2); imagesc(DBruteBinary); title('10 Nearest Neighbors Brute Force');
subplot(1, 3, 3); imagesc(DBrute < k); title('10 Percent Cutoff');
print('-dpng', '-r100', sprintf('%i_%iBruteForce.png', idx1, idx2));