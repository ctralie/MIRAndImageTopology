list1 = '../covers80/covers32k/list1.list';
list2 = '../covers80/covers32k/list2.list';

files2 = textread(list2, '%s\n');
N = length(files2);
beatDownsample = 2;

for K = [4, 8, 16]
    for dim = [100, 200]
        for BeatsPerWin = [1, 2, 4, 8, 16]
            filename = sprintf('DictResults_%i_%i_%i.mat', K, dim, BeatsPerWin);
            if ~exist(filename)
                fprintf(1, 'Doing %s\n', filename);
                D = zeros(length(files2), length(files2));
                Dicts = load(sprintf('SongDicts_%i_%i_%i.mat', K, dim, BeatsPerWin));
                Dicts = Dicts.Ds;
                parfor ii = 1:N
                    fprintf(1, 'Doing %s\n', files2{ii});
                    [~, fits] = representSongWithDictionaries(files2{ii}, Dicts, dim, BeatsPerWin, beatDownsample)
                    D(ii, :) = fits;
                end
                save(filename, 'D');
            else
                load(filename);
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
            print('-dpng', '-r100', sprintf('DictResults_%i_%i_%i.png', K, dim, BeatsPerWin));
        end
    end
end

