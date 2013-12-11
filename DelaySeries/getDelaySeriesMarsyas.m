function [DelaySeries] = getDelaySeriesMarsyas( filename, hopSize, windowSize )
    NFeatures = 124;
    [pathstr, name, ~] = fileparts(filename);
    wavprefix = name;
    if ~isempty(pathstr)
        wavprefix = sprintf('%s/%s', pathstr, name);
    end
    [X, fs] = audioread(filename);
    if size(X, 2) > 1
       %Merge to mono if there is more than one channel
       X = sum(X, 2)/size(X, 2); 
    end
    %The delay offsets in the delay series
    offsets = 1:hopSize:length(X) - windowSize -1;
    DelaySeries = zeros(length(offsets), NFeatures);
    index = 1;
    for ii = offsets
        wavfilename = sprintf('%s_%i.wav', wavprefix, index);
        XSample = X(ii:ii+windowSize-1);
        audiowrite(wavfilename, XSample, fs);
        pause(0.1);
        [~, result] = system(sprintf('python getDelayFeatures.py %s', wavfilename));
        result = str2num(result);
        DelaySeries(index, :) = result;
        if (mod(index, 100) == 0)
            fprintf(1, 'Finished %i of %i\n', index, length(offsets));
        end
        %system(sprintf('rm %s', wavfilename));
        index = index + 1;
    end
end