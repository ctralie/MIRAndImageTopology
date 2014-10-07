%Get the raw delay embedding of the song (no CAFs)
function [ DelaySeries ] = getDelaySeriesRaw( filename, hopSize, skipSize, windowSize )
    %Prevents the mandlebug where matlab's audio read randomly fails
    readSuccess = 0;
    while readSuccess == 0
        try
            [X, Fs] = audioread(filename);
            readSuccess = 1;
        catch
            readSuccess = 0;
        end
    end
    if size(X, 2) > 1
       %Merge to mono if there is more than one channel
       X = sum(X, 2)/size(X, 2); 
    end
    
    M = hopSize*windowSize;
    N = length(1:hopSize*skipSize:length(X)-hopSize*windowSize-1);
    DelaySeries = zeros(N, M);
    for ii = 1:N
       DelaySeries(ii, :) = X( (ii-1)*hopSize + (1:hopSize*windowSize));
    end
end