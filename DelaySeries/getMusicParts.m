%Return a sound file which is only taken at the specified sample indices
function [ X, Fs] = getMusicParts( filename, samples, hopSize, skipSize, windowSize)
    [Y, Fs] = audioread(filename);
    if size(Y, 2) > 1
       %Merge to mono if there is more than one channel
       Y = sum(Y, 2)/size(Y, 2); 
    end
    X = zeros(size(Y));
    length(X)
    factor = hopSize*skipSize;
    windowLen = hopSize*windowSize;
    for ii = 1:length(samples)
        starti = (samples(ii)-1)*factor+1;
        endi = starti + windowLen;
        if endi > length(X)
            endi = length(X);
        end
        fprintf(1, 'starti = %i, endi = %i\n', starti, endi);
        indices = starti:endi;
        X(indices) = Y(indices);
    end
end