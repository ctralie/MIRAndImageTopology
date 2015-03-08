list1 = '../covers80/covers32k/list1.list';
list2 = '../covers80/covers32k/list2.list';

files1 = textread(list1, '%s\n');
files2 = textread(list2, '%s\n');
N = length(files1);

dim = 200;
BeatsPerWin = 8;
Ms = cell(N, N);

DsOrig = cell(1, N);
parfor ii = 1:N
    fprintf(1, 'Doing %s\n', files1{ii});
    DsOrig{ii} = single(getBeatSyncDistanceMatricesSlow(files1{ii}, dim, BeatsPerWin));
end

for ii = 1:N
    fprintf(1, 'Doing %i of %i\n', ii, N);
    tic
    D = single(getBeatSyncDistanceMatricesSlow(files2{ii}, dim, BeatsPerWin));
    for jj = 1:N
        Ms{ii}{jj} = pdist2(DsOrig{jj}, D);
        fprintf(1, '.');
    end
    fprintf(1, '\n');
    toc
end

save(sprintf('AllDissimilarities%i.mat', BeatsPerWin), 'Ms');
