function [ DOut ] = getBeatSyncEMDWavelets( sprefix, dim, BeatsPerWin, beatDownsample )
    addpath('ApproximateWaveletEMD_release');
    addpath('../ImageWarp');
    D = getBeatSyncDistanceMatricesSlow(sprefix, dim, BeatsPerWin, beatDownsample);
    DOut = cell(size(D, 1), 1);
    parfor ii = 1:size(D, 1)
        thisD = reshape(D(ii, :), [dim dim]);
        %Normalize mass for EMD
        s = wemdn(thisD/sum(thisD(:)), 0);
        DOut{ii} = s';
    end
    DOut = cell2mat(DOut);
end

