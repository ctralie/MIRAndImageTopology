NSongs = 1;

%Model a 3 minute song with a tempo of 120 bpm
%Assume 2 beats per window
SamplesPerWin = 200;
Fac = 10;
NPoints = round(60*3/(1.0/SamplesPerWin)/10);

%TODO: Model different types of corruptions
%1) Pulling a few regions away in random directions
%2) Adding intro/outro
%3) Adding sections of song that shouldn't be there
for kk = 1:NSongs
    X = makeRandomWalkCurve(500, NPoints, 3);
    X = smoothCurve(X, Fac);
    [Y, corruptedIdx] = corruptRandomBeats(X, SamplesPerWin, 20, 3);
    %Y = applyRandomTransformation(Y);
    NWindows = size(X, 1)/(SamplesPerWin/2) - 1;
    PointClouds1 = cell(1, NWindows);
    PointClouds2 = cell(1, NWindows);
    C = colormap('jet');
    C = C(1 + floor((1:SamplesPerWin)*64/(SamplesPerWin+1)), :);
    for ii = 1:NWindows
        idx = (SamplesPerWin/2)*(ii-1) + (1:SamplesPerWin);
        PC1 = X(idx, :);
        PC2 = Y(idx, :);
        PointClouds1{ii} = PC1;
        PointClouds2{ii} = PC2;

        PC1 = bsxfun(@minus, mean(PC1), PC1);
        Norm = 1./(sqrt(sum(PC1.*PC1, 2)));
        PC1 = PC1.*(repmat(Norm, [1 size(PC1, 2)]));        

        PC2 = bsxfun(@minus, mean(PC2), PC2);
        Norm = 1./(sqrt(sum(PC2.*PC2, 2)));
        PC2 = PC2.*(repmat(Norm, [1 size(PC2, 2)]));           
        
        subplot(2, 2, 1);
        scatter3(PC1(:, 1), PC1(:, 2), PC1(:, 3), 20, C);
        title('Simulated Original');
        subplot(2, 2, 2);
        imagesc(squareform(pdist(PC1)));
        
        subplot(2, 2, 3);
        scatter3(PC2(:, 1), PC2(:, 2), PC2(:, 3), 20, C);
        title('Simulated Cover');
        subplot(2, 2, 4);
        imagesc(squareform(pdist(PC2)));
        if (~isempty(find(corruptedIdx == ii)))
            title('Corrupted');
        end
        
        print('-dpng', '-r100', sprintf('%i.png', ii));
    end
end

