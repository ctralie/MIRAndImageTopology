function [ D ] = getL2FourierMagCrossSimilarity( file1, file2, dim, BeatsPerWin, Ds1, Ds2 )
    addpath('..');
    if nargin < 5
        Ds1 = getBeatSyncDistanceMatricesSlow(file1, dim, BeatsPerWin);
    end
    if nargin < 6
        Ds2 = getBeatSyncDistanceMatricesSlow(file2, dim, BeatsPerWin);
    end
    N = size(Ds1, 1);
    M = size(Ds2, 1);
    D = zeros(N, M);
    disp('Doing FFTs for matrix 1...');
    parfor ii = 1:N
        V = abs(fft2(reshape(Ds1(ii, :), dim, dim)));
        Ds1(ii, :) = V(:)';
    end
    disp('Doing FFTs for matrix 2...');
    parfor ii = 1:M
        V = abs(fft2(reshape(Ds2(ii, :), dim, dim)));
        Ds2(ii, :) = V(:)';
    end
    disp('Doing pdist2...');
    D = pdist2(Ds1, Ds2);
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