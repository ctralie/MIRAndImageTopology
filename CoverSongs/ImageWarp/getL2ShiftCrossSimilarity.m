function [ D ] = getL2ShiftCrossSimilarity( file1, file2, dim, BeatsPerWin, shift )
    addpath('..');
    Ds1 = getBeatSyncDistanceMatricesSlow(file1, dim, BeatsPerWin);
    Ds2 = getBeatSyncDistanceMatricesSlow(file2, dim, BeatsPerWin);
    N = size(Ds1, 1);
    M = size(Ds2, 1);
    N = 100;
    M = 100;    
    D = zeros(N, M);
    
    for ii = 1:N
        tic
        fprintf(1, 'Doing %i of %i\n', ii, N);
        thisD = zeros(1, size(D, 2));
        D1 = reshape(Ds1(ii, :), dim, dim);
        parfor jj = 1:M
            thisD(jj) = getL2DistWithShiftsMex(D1, reshape(Ds2(jj, :), dim, dim), shift);
            fprintf(1, '.');
        end
        D(ii, :) = thisD;
        fprintf(1, '\n');
        toc
    end
end

% save('ShiftL2.mat', 'CSL2', 'CSL2Shift2', 'CSL2Shift5', 'CSL2Shift10');
% cutoff = 0.1;
% subplot(2, 4, 1); imagesc(CSL2); title('L2');
% subplot(2, 4, 2); imagesc(CSL2Shift2); title('L2 Shift 2');
% subplot(2, 4, 3); imagesc(CSL2Shift5); title('L2 Shift 5'); 
% subplot(2, 4, 4); imagesc(CSL2Shift10); title('L2 Shift 10');
% k = quantile(CSL2(:), cutoff); subplot(2, 4, 5); imagesc(CSL2 < k); 
% k = quantile(CSL2Shift2(:), cutoff); subplot(2, 4, 6); imagesc(CSL2Shift2 < k);
% k = quantile(CSL2Shift5(:), cutoff); subplot(2, 4, 7); imagesc(CSL2Shift5 < k); 
% k = quantile(CSL2Shift10(:), cutoff); subplot(2, 4, 8); imagesc(CSL2Shift10 < k); 