%windowSize: Window size in seconds
function [Y] = getSongPointCloud( song, windowSize )
    MFCCSAMPLELEN = 0.016;

    MFCC = readhtk(sprintf('../mfccs/%s.htk', song));
    %TODO: Incorporate chroma later
%     Chroma = load(sprintf('../chromaftrs/%s.mat', song));
%     ChromaX = Chroma.F';
    MFCCWindowSize = round(windowSize/MFCCSAMPLELEN);%Each MFCC window is 15 milliseconds
%    p = (size(MFCC, 2) + length(Chroma.bts))*2;
    p = (size(MFCC, 2))*2;
    N = size(MFCC, 1) - MFCCWindowSize;
    Y = zeros(N, p);
    for ii = 1:N
        idx = ii:ii+MFCCWindowSize-1;
        MFCCFeats = [mean(MFCC(idx, :)) std(MFCC(idx, :))];
        %chromaStart = find(Chroma.bts > (idx-1)*MFCCSAMPLELEN
        Y(ii, :) = MFCCFeats;
    end
    Y = bsxfun(@minus, mean(Y), Y);
    Y = bsxfun(@times, 1./std(Y), Y);
end