function [ D ] = getPatchHausdorffCrossSimilarity( file1, file2, dim, patchdim, posWeight, BeatsPerWin )
    addpath(genpath('flann_wrapper'));
    Ds1 = getBeatSyncDistanceMatricesSlow(file1, dim, BeatsPerWin);
    Ds2 = getBeatSyncDistanceMatricesSlow(file2, dim, BeatsPerWin);
    N = size(Ds1, 1);
    M = size(Ds2, 1);
    N = 50;
    M = 50;
    D = zeros(N, M);
    
    params.algorithm = 'autotuned';
    params.target_precision = 0.95;
    params.build_weight = 0.01;
    params.memory_weight = 0.5;
    
    for ii = 1:N
        tic
        X = embedDissimilarityPatches(reshape(Ds1(ii, :), dim, dim), patchdim, posWeight);
        fprintf(1, 'Doing %i of %i\n', ii, N);
        index = flann_build_index(X', params);
        for jj = 1:M
            Y = embedDissimilarityPatches(reshape(Ds2(jj, :), dim, dim), patchdim, posWeight);
            [~, dists] = flann_search(index, Y', 1, params);
            D(ii, jj) = sum(dists);
            fprintf(1, '.');
        end
        fprintf(1, '\n');
        toc
    end
end

