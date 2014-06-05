function [I, J, JGenerators, D] = doVideoHomology( filename )
    addpath('../ImageToolbox/channels');
    addpath('../TDAMex');
    obj = VideoReader(filename);
    N = obj.NumberOfFrames;
    SampleDelays = linspace(0, obj.Duration, N);
    hogs = [];
    hogsavg = [];
    fprintf(1, 'Doing HOG on %i frames...\n', N);
    lastFrame = single(rgb2gray(read(obj, 1)));
    for n = 2:N
        thisFrame = single(rgb2gray(read(obj, n)));
        I = thisFrame - lastFrame;
        lastFrame = thisFrame;
        %I = thisFrame;
        hog = fhog(I, 16, 9);
        if isempty(hogs)
           hogs = zeros(N, length(hog(:)));
           hogsavg = zeros(N, size(hog, 3));
        end
        hogs(n, :) = hog(:);
        hogsavg(n, :) = squeeze(sum(sum(hog, 1), 2));
        fprintf(1, '.');
        if mod(n, 50) == 0
           fprintf(1, '\n'); 
        end
    end
    D = squareform(pdist(hogs));
    DAvg = squareform(pdist(hogsavg));
    minDist = min(D(:));
    maxDist = max(D(:));
    
    [I, J, JGenerators] = getGeneratorsFromTDAJar(D, maxDist);
    plotPersistenceDiagrams(I, J, minDist, maxDist);
    [~, genOrder] = sort(J(:, 2));%Sort the points in increasing order of death time
    dimx = 5;
    figure;
    for i = 1:dimx*dimx
       subplot(dimx, dimx, i);
       %plot(SampleDelays(JGenerators{genOrder(i)}));
       plot(JGenerators{genOrder(i)});
       xlabel('Sample Number');
       ylabel('Frame Number');
       title( sprintf('%g', J(genOrder(i), 2) - J(genOrder(i), 1)) );
    end
    
%     disp('Doing CMDS....');
%     [Y, eigvals] = cmdscale(D);
%     [YAvg, eigvalsavg] = cmdscale(DAvg);
%     
%     subplot(2, 2, 1);
%     gscatter(Y(:, 1), Y(:, 2), 1:N);
%     title('MDS of HOG Features');
%     subplot(2, 2, 2);
%     title('Eigenvalues of HOG Features');
%     plot(eigvals);
% 
%     subplot(2, 2, 3);
%     gscatter(YAvg(:, 1), YAvg(:, 2), 1:N);
%     title('MDS of Average HOG Features');
%     subplot(2, 2, 4);
%     title('Eigenvalues of Average HOG Features');
%     plot(eigvalsavg);
%     
%     figure;
%     nstart = 111;
%     ntotal = 10;
%     for periods = 1:3
%         figure;
%         thisnstart = nstart+ntotal*(periods-1);
%         for n = thisnstart:thisnstart+ntotal-1
%             thisn = n - nstart;
%             startindex = (n-thisnstart)*2;
% 
%             subplot(ntotal, 2, startindex+1);
%             imagesc(read(obj, n));
%             axis off;
%             subplot(ntotal, 2, startindex+2);
%             plot((hogsavg(n, :) - hogsavg(nstart, :))./hogsavg(nstart));
%             ylim([-0.2, 0.2]);
%         end
%     end
end