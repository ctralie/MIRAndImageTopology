%windowSize: Window size in seconds
%analysisWinSize: Length in seconds of analysis window
function [Y, MFCCWindowLEN] = getSongPointCloud( song, windowSize, subsample )
    MFCCSAMPLELEN = 0.016;

    filename = sprintf('../mfccs/%s.htk', song);
    MFCC = readhtk(filename);

    %TODO: Incorporate chroma later
%     Chroma = load(sprintf('../chromftrs/%s.mat', song));
%     ChromaX = Chroma.F';
    MFCCWindowLEN = round(windowSize/MFCCSAMPLELEN);%Each MFCC window is 16 milliseconds
%    p = (size(MFCC, 2) + length(Chroma.bts))*2;
    p = (size(MFCC, 2))*2;
    N = size(MFCC, 1) - MFCCWindowLEN;
    Y = zeros(N, p);
    for ii = 1:N
        idx = ii:ii+MFCCWindowLEN-1;
        MFCCFeats = [mean(MFCC(idx, :)) std(MFCC(idx, :))];
        %chromaStart = find(Chroma.bts > (idx-1)*MFCCSAMPLELEN
        Y(ii, :) = MFCCFeats;
    end
    Y = bsxfun(@minus, mean(Y), Y);
    Y = bsxfun(@times, 1./std(Y), Y);
    Y = Y(1:subsample:end, :);
    
    fprintf(1, 'Read %s, size %i\n', filename, size(Y, 1));    
end
