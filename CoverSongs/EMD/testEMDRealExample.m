list1 = '../covers80/covers32k/list1.list';
list2 = '../covers80/covers32k/list2.list';
files1 = textread(list1, '%s\n');
files2 = textread(list2, '%s\n');

disp('Getting L2 matrix 1...');
tic; D1L2 = getBeatSyncDistanceMatricesSlow(files1{76}, 200, 8, 1); toc;
disp('Getting L2 matrix 2...');
tic; D2L2 = getBeatSyncDistanceMatricesSlow(files2{76}, 200, 8, 1); toc;
disp('Getting EMD matrix 1...');
tic; D1EMD = getBeatSyncEMDWavelets(files1{76}, 200, 8, 1); toc;
disp('Getting EMD matrix 2...');
tic; D2EMD = getBeatSyncEMDWavelets(files2{76}, 200, 8, 1); toc;

disp('Getting cross-similarity L2');
tic; DL2 = pdist2(D1L2, D2L2); toc;
disp('Getting cross-similarity EMD');
tic; DEMD = pdist2(D1EMD, D2EMD, 'cityblock'); toc;

subplot(1, 2, 1);  imagesc(DL2);  title('L2');
subplot(1, 2, 2);  imagesc(DEMD); title('EMD');