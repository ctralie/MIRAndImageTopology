list1 = '../covers80/covers32k/list1.list';
list2 = '../covers80/covers32k/list2.list';
addpath('../SequenceAlignment');

files1 = textread(list1, '%s\n');
files2 = textread(list2, '%s\n');
N = length(files1);

BeatsPerWin = 10;
beatDownsample = 1;

CSMs = cell(N, N);
Scores = zeros(N, N);
OTIs = zeros(N, N);
Sizes = cell(N, N);

%First do a global OTI, then do local OTIs
for ii = 1:N
    [X, CX] = getBeatSyncChromaDelay(files1{ii}, BeatsPerWin);
    thisCSMs = cell(1, N);
    thisOTIs = zeros(1, N);
    thisScores = zeros(1, N);
    thisSizes = cell(1, N);
    fprintf(1, 'Doing %s...\n', files1{ii});
    parfor jj = 1:N
        [Y, CY] = getBeatSyncChromaDelay(files2{jj}, BeatsPerWin);
        tic;
        [oti, corrs] = getGlobalOTI(CX, CY);%Get global OTI
        fprintf(1, 'OTI between %i and %i is %i\n', ii, jj, oti);
        
        allScores = zeros(1, size(Y, 2));
        Comp = zeros(size(X, 1), size(Y, 1), size(Y, 2));%Full oti comparison matrix
        %Do OTI on each element individually
        for cc = 0:size(Y, 2)-1
            thisY = getBeatSyncChromaDelay(files2{jj}, BeatsPerWin, cc+oti, CY);
            Comp(:, :, cc+1) = X*thisY';
        end
        [~, Comp] = max(Comp, [], 3);
        CSM = (Comp == 1) + (Comp == 2) + (Comp == size(Y, 2));
        CSM(CSM > 0) = 1;
        CSM = double(CSM);
        allScores(oti+1) = swalignimp(CSM);
        [thisScores(jj), thisOTIs(jj)] = max(allScores);
        thisOTIs(jj) = thisOTIs(jj) - 1;
        thisCSMs{jj} = sparse(CSM);
        thisSizes{jj} = size(CSM);
        toc
    end
    CSMs(ii, :) = thisCSMs;
    Scores(ii, :) = thisScores;
    OTIs(ii, :) = thisOTIs;
    Sizes(ii, :) = thisSizes;
end

save(sprintf('ResultsDelay%i.mat', BeatsPerWin), 'Scores', 'OTIs', 'Sizes');

L = zeros(1, 80);
for ii = 1:80
    song = load(['../covers80/TempoEmbeddings/', files2{ii}, '.mat']);
    L(ii) = length(song.bts);
end
