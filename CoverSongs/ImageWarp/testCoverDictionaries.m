list1 = '../covers80/covers32k/list1.list';
list2 = '../covers80/covers32k/list2.list';

files2 = textread(list2, '%s\n');
N = length(files2);
K = 8;
dim = 100;

for BeatsPerWin = 4
    D = zeros(length(files2), length(files2));
    Dicts = load(sprintf('SongDicts%i.mat', BeatsPerWin));
    Dicts = Dicts.Ds;
    parfor ii = 1:N
        fprintf(1, 'Doing %s\n', files2{ii});
        [~, fits] = representSongWithDictionaries(files2{ii}, Dicts, dim, BeatsPerWin)
        D(ii, :) = fits;
    end
    [~, idx] = min(D, [], 2);
    imagesc(D);
    colormap('gray');
    hold on;
    equalidx = 1:80;
    equalidx = equalidx(idx' == 1:80);
    for ii = 1:length(idx)
        if ii == idx(ii)
            scatter(idx(ii), ii, 30, 'g', 'fill');
        else
            scatter(idx(ii), ii, 30, 'r', 'fill');
            scatter(ii, ii, 10, 'b', 'fill');
        end
    end
    title(sprintf('%i of %i correct', sum(1:80 == idx'), 80));    
end

