list1 = '../covers80/covers32k/list1.list';
list2 = '../covers80/covers32k/list2.list';

files1 = textread(list1, '%s\n');
files2 = textread(list2, '%s\n');
N = length(files1);

dim = 200;
for BeatsPerWin = [8, 4, 6]
    Ms = cell(N, N);

    for ii = 1:N
        fprintf(1, 'Doing %i of %i\n', ii, N);
        file1 = ['../covers80/TempoEmbeddings/', files1{ii}, '.mat'];
        row = cell(1, N);
        parfor jj = 1:N
            file2 = ['../covers80/TempoEmbeddings/', files2{jj}, '.mat'];
            tic
            row{jj} = single(getCurvSimilarity(file1, file2, BeatsPerWin));
            toc
        end
        Ms(ii, :) = row;
        fprintf(1, '\n');
    end

    save(sprintf('AllDissimilarities%i.mat', BeatsPerWin), 'Ms', '-v7.3');
end
