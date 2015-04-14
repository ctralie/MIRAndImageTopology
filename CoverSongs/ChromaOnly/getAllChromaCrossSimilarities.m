list1 = '../covers80/covers32k/list1.list';
list2 = '../covers80/covers32k/list2.list';
addpath('../SequenceAlignment');

files1 = textread(list1, '%s\n');
files2 = textread(list2, '%s\n');
N = length(files1);

%BeatsPerWin = 10;
beatDownsample = 1;
Kappa = 0.1;

Scores = zeros(N, N, 4);
OTIs = zeros(N, N, 4);
Sizes = cell(N, N);

%First do a global OTI, then do local OTIs
for BeatsPerWin = [1, 2, 4, 8, 12]
    for ii = 1:N
        [X, CX] = getBeatSyncChromaDelay(files1{ii}, BeatsPerWin);
        thisOTIs = zeros(N, 4);
        thisScores = zeros(N, 4);
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
                CSM2 = (Comp == 1) + (Comp == 2) + (Comp == 3) + (Comp == size(Y, 2)) + (Comp == size(Y, 2)-1);
                CSM2(CSM2 > 0) = 1;
                CSM0 = double(CSM0);
                CSM1 = double(CSM1);
                CSM2 = double(CSM2);

                thisY = getBeatSyncChromaDelay(files2{jj}, BeatsPerWin, oti, CY);
                D = pdist2(X, thisY);
                k = quantile(D(:), Kappa);
                D = double(D < k);
                allScores(oti+1, 1) = swalignimp(CSM0);
                allScores(oti+1, 2) = swalignimp(CSM1);
                allScores(oti+1, 3) = swalignimp(CSM2);
                allScores(oti+1, 4) = swalignimp(D);
            end
            [ss, oo] = max(allScores, [], 1);
            thisScores(jj, :) = ss;
            fprintf(1, '%i - %i:', ii, jj);
            thisScores(jj, :)
            thisOTIs(jj, :) = oo-1;
            thisSizes{jj} = size(CSM0);
            toc
        end
        Scores(ii, :, :) = thisScores;
        OTIs(ii, :, :) = thisOTIs;
        Sizes(ii, :) = thisSizes;
    end

    save(sprintf('ResultsDelay%i.mat', BeatsPerWin), 'Scores', 'OTIs', 'Sizes');

    setpref('Internet', 'E_mail', 'labmailciemas3418@gmail.com');
    setpref('Internet', 'SMTP_Server', 'smtp.gmail.com');
    setpref('Internet', 'SMTP_Username', 'labmailciemas3418@gmail.com');
    setpref('Internet', 'SMTP_Password', 'r3yn0ldsL@b');
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    sendmail('chris.tralie@gmail.com', sprintf('Finished chroma experiments BeatsPerWin = %i', BeatsPerWin));
end

L = zeros(1, 80);
for ii = 1:80
    song = load(['../covers80/TempoEmbeddings/', files2{ii}, '.mat']);
    L(ii) = length(song.bts);
end

S = zeros(80, 80);
for ii = 1:80
    for jj = 1:80
        S(ii, jj) = sqrt(Sizes{ii, jj}(2));%prod(Sizes{ii, jj});
    end
end
S = repmat(S, [1 1 size(Scores, 3)]);
%ScoresScaled = bsxfun(@times, S, 1./Scores);
ScoresScaled = S./Scores;

for ii = 1:size(Scores, 3)
    [~, idx] = min(squeeze(ScoresScaled(:, :, ii)), [], 2);
    sum(idx' == 1:80)
end
