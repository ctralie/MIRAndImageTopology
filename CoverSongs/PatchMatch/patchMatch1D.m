function [ NNF, Queries ] = patchMatch1D( Ds1, Ds2, NIters, K, NNType )
%Wrapper function around Patch Match 1D MEX
    N = size(Ds1, 1);
    M = size(Ds2, 1);
    NNFInit = randi(M, N, K);
    DebiasRs = 2*rand(1, N*NIters) - 1;
    [NNF, Queries] = patchMatch1DMEX(Ds1, Ds2, NNFInit, DebiasRs, NIters, K, NNType);
end

