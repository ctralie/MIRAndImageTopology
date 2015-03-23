%Make the dictionaries by having each column be the distance matrix for one
%beat
addpath('../SequenceAlignment');
addpath('../ImageWarp');
list1 = '../covers80/covers32k/list1.list';
list2 = '../covers80/covers32k/list2.list';
files1 = textread(list1, '%s\n');
files2 = textread(list2, '%s\n');

%First initialize all of the dictionaries to be the beats in all of the
%songs
dim = 200;
BeatsPerWin = 8;
beatDownsample = 2;
Dicts = cell(1, 80);
disp('Initializing Dictionaries...');
for ii = 1:80
    ii
    Dicts{ii} = getBeatSyncDistanceMatricesSlow(files1{ii}, dim, BeatsPerWin, beatDownsample)';
end
disp('Finished Initializing Dictionaries');
Correct = zeros(3, 2);
lambdaidx = 1;
for lambda = [0.1, 1, 10]
    DFit = zeros(80, 80);
    DAlphaAlign = zeros(80, 80);
    for ii = 1:80
        fprintf(1, 'Doing %i of %i...\n', ii, 80);
        [alphas, fits] = representSongWithDictionaries(files2{ii}, Dicts, dim, BeatsPerWin, beatDownsample);
        DFit(ii, :) = fits;
        for jj = 1:80
            M = full(double(alphas{jj} > 0));
            DAlphaAlign(ii, jj) = swalignimp(M)/sum(size(M));
        end
    end
    [~, idx] = max(DAlphaAlign, [], 2);
    AlphaCorrect = sum(idx' == 1:80);
    [~, idx] = min(DFit, [], 2);
    FitCorrect = sum(idx' == 1:80);
    save(sprintf('SelfDictResults%g.png', lambda), 'DFit', 'DAlphaAlign', 'FitCorrect', 'AlphaCorrect');
    Correct(lambdaidx, 1) = FitCorrect;
    Correct(lambdaidx, 2) = AlphaCorrect;
    lambdaidx = lambdaidx + 1;
end