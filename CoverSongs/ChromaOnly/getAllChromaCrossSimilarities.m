list1 = '../covers80/covers32k/list1.list';
list2 = '../covers80/covers32k/list2.list';
addpath('../SequenceAlignment');

files1 = textread(list1, '%s\n');
files2 = textread(list2, '%s\n');
N = length(files1);

BeatsPerWin = 10;
beatDownsample = 1;
Kappa = 0.1;

CSMs = cell(N, N);
Scores = zeros(N, N, 3);
OTIs = zeros(N, N, 3);
Sizes = cell(N, N);

%First do a global OTI, then do local OTIs
for ii = 1:N
    [X, CX] = getBeatSyncChromaDelay(files1{ii}, BeatsPerWin);
    thisCSMs = cell(1, N);
    thisOTIs = zeros(N, 3);
    thisScores = zeros(N, 3);
    thisSizes = cell(1, N);
    fprintf(1, 'Doing %s...\n', files1{ii});
    parfor jj = 1:N
        [Y, CY] = getBeatSyncChromaDelay(files2{jj}, BeatsPerWin);
        tic;
%         [oti, corrs] = getGlobalOTI(CX, CY);%Get global OTI
%         fprintf(1, 'OTI between %i and %i is %i\n', ii, jj, oti);
        
        allScores = zeros(size(Y, 2), 3);
        for oti = 0:size(CY, 2)-1
            Comp = zeros(size(X, 1), size(Y, 1), size(Y, 2));%Full oti comparison matrix
            %Do OTI on each element individually
            for cc = 0:size(Y, 2)-1
                thisY = getBeatSyncChromaDelay(files2{jj}, BeatsPerWin, cc+oti, CY);
                Comp(:, :, cc+1) = X*thisY';
            end
            [~, Comp] = max(Comp, [], 3);
            %Try out OTI with 0 fudge factor, OTI with 1 fudge factor
            %and binary threshold
            CSM0 = (Comp == 1);
            CSM1 = (Comp == 1) + (Comp == 2) + (Comp == size(Y, 2));
            CSM1(CSM1 > 0) = 1;
            CSM0 = double(CSM0);
            CSM1 = double(CSM1);
            
            thisY = getBeatSyncChromaDelay(files2{jj}, BeatsPerWin, oti, CY);
            D = pdist2(X, thisY);
            k = quantile(D(:), Kappa);
            D = double(D < k);
            allScores(oti+1, 1) = swalignimp(CSM0);
            allScores(oti+1, 2) = swalignimp(CSM1);
            allScores(oti+1, 3) = swalignimp(D);
        end
        [ss, oo] = max(allScores, [], 1);
        thisScores(jj, :) = ss;
        fprintf(1, '%i - %i:', ii, jj);
        thisScores(jj, :)
        thisOTIs(jj, :) = oo-1;
        thisCSMs{jj} = sparse(CSM);
        thisSizes{jj} = size(CSM);
        toc
    end
    CSMs(ii, :) = thisCSMs;
    Scores(ii, :, :) = thisScores;
    OTIs(ii, :, :) = thisOTIs;
    Sizes(ii, :) = thisSizes;
end

save(sprintf('ResultsDelay%i.mat', BeatsPerWin), 'Scores', 'OTIs', 'Sizes');




L = zeros(1, 80);
for ii = 1:80
    song = load(['../covers80/TempoEmbeddings/', files2{ii}, '.mat']);
    L(ii) = length(song.bts);
end

S = zeros(80, 80);
for ii = 1:80
    for jj = 1:80
        S(ii, jj) = prod(Sizes{ii, jj});
    end
end
%ScoresScaled = bsxfun(@times, S, 1./Scores);
ScoresScaled = S./Scores;



