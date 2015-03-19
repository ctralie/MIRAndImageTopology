function [ DMax, DSum ] = get3DMeshHausdorffCrossSimilarity( file1, file2, dim, BeatsPerWin )
    Ds1 = getBeatSyncDistanceMatricesSlow(file1, dim, BeatsPerWin);
    Ds2 = getBeatSyncDistanceMatricesSlow(file2, dim, BeatsPerWin);
    N = size(Ds1, 1);
    M = size(Ds2, 1);
    DSum = zeros(N, M);
    DMax = zeros(N, M);
    
    %Set up location grid
    [XLocs, YLocs] = meshgrid(linspace(0, 1, dim), linspace(0, 1, dim));
    Locs = [XLocs(:) YLocs(:)];
    
    for ii = 1:N
        tic
        X = [Locs Ds1(ii, :)'];
        fprintf(1, 'Doing %i of %i\n', ii, N);
        DTX = delaunayTriangulation(X);
        thisDSum = zeros(1, size(DSum, 2));
        thisDMax = zeros(1, size(DMax, 2));
        parfor jj = 1:M
            Y = [Locs Ds2(jj, :)'];
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