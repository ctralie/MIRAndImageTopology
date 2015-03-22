list1 = '../covers80/covers32k/list1.list';
list2 = '../covers80/covers32k/list2.list';

files1 = textread(list1, '%s\n');
files2 = textread(list2, '%s\n');
N = length(files1);
K = 8;
dim = 100;
beatDownsample = 2;

Ds = cell(N, 1);
for BeatsPerWin = 8
    for ii = 1:N
        fprintf(1, 'Doing %s\n', files1{ii});
        Ds{ii} = getDictionary(files1{ii}, K, dim, BeatsPerWin, beatDownsample);
    end
    save(sprintf('SongDicts%i.mat', BeatsPerWin), 'Ds');
end