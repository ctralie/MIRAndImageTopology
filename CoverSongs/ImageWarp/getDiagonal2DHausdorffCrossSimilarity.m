function [ DMax, DSum ] = getDiagonal2DHausdorffCrossSimilarity( file1, file2, dim, BeatsPerWin )
    Ds1 = getBeatSyncDistanceMatricesSlow(file1, dim, BeatsPerWin);
    Ds2 = getBeatSyncDistanceMatricesSlow(file2, dim, BeatsPerWin);
    N = size(Ds1, 1);
    M = size(Ds2, 1);
    DSum = zeros(N, M);
    DMax = zeros(N, M);
    
    %Set up location grid
    [XLocs, YLocs] = meshgrid(linspace(0, 1, dim), linspace(0, 1, dim));
    XLocs = XLocs(:);
    YLocs = YLocs(:);
    KeepIdx = XLocs >= YLocs;%Don't use redundant symmetric indices
    DiagDistApprox = abs(XLocs - YLocs);
    for ii = 1:N
        tic
        X = [DiagDistApprox(KeepIdx) Ds1(ii, KeepIdx)'];
        fprintf(1, 'Doing %i of %i\n', ii, N);
        DTX = delaunayTriangulation(X);
        thisDSum = zeros(1, size(DSum, 2));
        thisDMax = zeros(1, size(DMax, 2));
        for jj = 1:M
            Y = [DiagDistApprox(KeepIdx) Ds2(jj, KeepIdx)'];
            DTY = delaunayTriangulation(Y);
            [~, dists1] = DTX.nearestNeighbor(Y);
            [~, dists2] = DTY.nearestNeighbor(X);
            thisDSum(jj) = sum(dists1) + sum(dists2);
            thisDMax(jj) = max(max(dists1), max(dists2)); %This is true Hausdorff Distance
            fprintf(1, '.');
        end
        DSum(ii, :) = thisDSum;
        DMax(ii, :) = thisDMax;
        fprintf(1, '\n');
        toc
    end
end
% 
% subplot(2, 5, 1); imagesc(CSL2); title('L2');
% subplot(2, 5, 2); imagesc(CSHausdorff); title('Hausdorff 3D Mesh');
% subplot(2, 5, 3); imagesc(CSHausdorffSum); title('Hausdorff 3D Mesh Sum');
% subplot(2, 5, 4); imagesc(CSHausdorff2); title('Diag Distance Hausdorff');
% subplot(2, 5, 5); imagesc(CSHausdorffSum2); title('Diag Distance Hausdorff Sum');
% 
% subplot(2, 5, 6); k = quantile(CSL2(:), 0.05); imagesc(CSL2 < k); title('L2');
% subplot(2, 5, 7); k = quantile(CSHausdorff(:), 0.05); imagesc(CSHausdorff < k); title('Hausdorff 3D Mesh');
% subplot(2, 5, 8); k = quantile(CSHausdorffSum(:), 0.05); imagesc(CSHausdorffSum < k); title('Hausdorff 3D Mesh Sum');
% subplot(2, 5, 9); k = quantile(CSHausdorff2(:), 0.05); imagesc(CSHausdorff2 < k); title('Diag Distance Hausdorff');
% subplot(2, 5, 10); k = quantile(CSHausdorffSum2(:), 0.05); imagesc(CSHausdorffSum2 < k); title('Diag Distance Hausdorff Sum');