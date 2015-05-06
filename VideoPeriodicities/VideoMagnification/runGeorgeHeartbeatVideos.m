fs = dir('FaceDataIR');
fs = fs(3:end-1, :); %Omit ., .., and Results
foldernames = cell(1, length(fs));
fprintf(1, '<html><body>\n');
for ii = 1:length(fs)
    foldernames{ii} = fs(ii).name;
    personName = strsplit(foldernames{ii}, '_');
    personName = personName{3};
    fprintf(1, '<hr><h1>%s</h1><BR>\n', personName);
    fprintf(1, '<img src = %s/Keypoints.png>\n', foldernames{ii});
    fprintf(1, '<img src = %s/SSM.png>\n', foldernames{ii});
    fprintf(1, '<img src = %s/PulseIntervalHist.png>\n', foldernames{ii});
    fprintf(1, '<BR><BR>');
end
fprintf(1, '</body></html>\n\n\n');

for ii = 1:length(foldernames)
    foldername = foldernames{ii};
    personName = strsplit(foldername, '_');
    personName = personName{3};
    fprintf(1, 'Computing embedding for %s....\n', personName);
    folderoutname = sprintf('FaceDataIR/Results/%s', foldername);
    foldername = sprintf('FaceDataIR/%s', foldername);
    if ~exist(folderoutname)
        mkdir(folderoutname);
    end
%     if exist(sprintf('%s/EmbeddingData.mat', foldername))
%         continue;
%     end
    
    getFrameFnIR = @(ii) getFrameFnFolder(foldername, ii, 1);
    getFrameFnDepth = @(ii) getFrameFnFolder(foldername, ii, 2);
    N = getFrameFnIR(-1);

    %Try to estimate two points on the cheek, and assume they don't move too
    %much
    disp('Getting keypoints...');
    Keypoints = squeeze(getFaceKeypoints(getFrameFnIR));
    if isempty(squeeze(Keypoints))
        fprintf(1, 'Error: Could not detect all keypoints for %s\n', personName);
        continue;
    end
    Keypoints(:, end+1, :) = 0.5*(Keypoints(:, 20, :) + Keypoints(:, 32, :));
    Keypoints(:, end+1, :) = 0.5*(Keypoints(:, 29, :) + Keypoints(:, 38, :));
    thisFrame = getFrameFnIR(1);
    X = squeeze(Keypoints(1, :, :));
    clf;
    imagesc(thisFrame);
    hold on;
    plot(X(1:end-2, 1), X(1:end-2, 2), 'g.');
    scatter(X(end-1:end, 1), X(end-1:end, 2), 20, 'r', 'fill');
    print('-dpng', '-r100', sprintf('%s/Keypoints.png', foldername));
    print('-dpng', '-r100', sprintf('%s/Keypoints.png', folderoutname));

    idx = size(Keypoints, 2)-1:size(Keypoints, 2);
    pdim = 10;
    PatchRegions = getKeypointPatches( Keypoints, size(thisFrame), idx, pdim );
    DelayWindow = 30;
    [region, R, theta] = getPixelSubsetEmbedding( getFrameFnIR, PatchRegions, DelayWindow, 1, 1, 0 );
    save(sprintf('%s/EmbeddingData.mat', foldername), 'R', 'theta');
    save(sprintf('%s/EmbeddingData.mat', folderoutname), 'R', 'theta');
    
    D = squareform(pdist(R));
    clf;
    imagesc(D);
    title(sprintf('%s Self-Similarity Matrix', personName));
    print('-dpng', '-r100', sprintf('%s/SSM.png', foldername));
    print('-dpng', '-r100', sprintf('%s/SSM.png', folderoutname));
    
    dintervals = [];
    for ii = 1:size(D, 1)
        [~, idx] = findpeaks(D(ii, :));
        dintervals = [dintervals idx(2:end) - idx(1:end-1)];
    end
    dintervals = dintervals/30;
    clf;
    hist(dintervals, 100);
    h = hist(dintervals, 100);
    meanInt = mean(dintervals);
    hold on;
    stem([meanInt meanInt], [0, max(h(:))*1.05], 'r')
    xlabel('Peak Interval');
    ylabel('Count');
    title(sprintf('%s Average Detected Pulse %g BPM', personName, 60/meanInt));
    print('-dpng', '-r100', sprintf('%s/PulseIntervalHist.png', foldername));
    print('-dpng', '-r100', sprintf('%s/PulseIntervalHist.png', folderoutname));
end