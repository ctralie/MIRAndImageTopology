function [X, featureNames] = getDelaySeriesMarsyas( y, Fs, windowSize, hopSize )
%Inputs: y: signal, Fs: Sample rate
    wavwrite(y, Fs, 'temp.wav');
    fmf = fopen('temp.mf', 'w');
    fwrite(fmf, 'temp.wav');
    fclose(fmf);
    system(sprintf('bextract temp.mf -w temp.arff -fe -mfcc -zcrs -ctd -rlf -flx -chroma -ws %i -hp %i -m 1', windowSize, hopSize));
    
    %Now parse the ARFF file to get the features
    READING_ATTRIBUTES = 1;
    READING_DATA = 2;
    farff = fopen('temp.arff', 'r');
    line = fgets(farff);
    X = [];
    featureNames = {};
    state = READING_ATTRIBUTES;
    ii = 1;
    while ischar(line) && ii < 40
        if line(1) == '%'
            line = fgets(farff);
            continue
        end
        if state == READING_ATTRIBUTES
            if length(line) >= 10 && strcmp(line(1:10), '@attribute')
               featureNames{length(featureNames)+1} = line(12:end-5);
            elseif length(line) >= 5 && strcmp(line(1:5), '@data')
                state = READING_DATA;
            end
        elseif state == READING_DATA
            line = strsplit(line, ',');
            line = cell2mat(line);
            nextLine = str2mat(line);
            X = [X nextLine(:)];
        end
        line = fgets(farff);
    end
end