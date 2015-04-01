list1 = '../covers80/covers32k/list1.list';
files1 = textread(list1, '%s\n');
list2 = '../covers80/covers32k/list2.list';
files2 = textread(list2, '%s\n');

counts = zeros(1, 80);
DAll = zeros(80, 80);
for K = [4, 8, 16]
    for dim = [100, 200]
        for BeatsPerWin = [1, 2, 4, 8, 16]
            filename = sprintf('LearnedDicts/DictResults_%i_%i_%i.mat', K, dim, BeatsPerWin);
            load(filename);
            [~, idx] = min(D, [], 2);
            equalidx = (idx' == 1:80);
            counts = counts + double(equalidx);
            DAll = DAll + D;%/sqrt(sum(D(:).^2));
        end
    end
end

[~, idx] = min(DAll, [], 2);
equalidx = (idx' == 1:80);
sum(equalidx)