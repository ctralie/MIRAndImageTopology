function [X, featureNames] = getBestHistoMarsyas( filename )
%Inputs: y: signal, Fs: Sample rate
    fprintf(1, 'Loading and converting %s...\n', filename);
    [y, Fs] = audioread(filename);
    wavwrite(y, Fs, 'temp.wav');
    fmf = fopen('temp.mf', 'w');
    fwrite(fmf, 'temp.wav');
    fclose(fmf);
    fprintf(1, 'Finished loading and converting %s\n', filename);

    %Default Parameters
    hopSize = round(2048*Fs/44100.0);
    skipSize = 1;
    windowSize = 1;%By default do not use a texture window  
    
    system(sprintf('bextract temp.mf -w temp.arff -sv -bf -ws %i -hp %i -m %i', hopSize, skipSize, windowSize));
    
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
            lineSplit = strsplit(line, ',');
            lineSplit = lineSplit(1:end-1);
            lineSplit = str2num(str2mat(lineSplit));
            X = [X lineSplit(:)];
        end
        line = fgets(farff);
    end
    featureNames = reshape(featureNames, [length(featureNames), 1]);
    featureNames = featureNames(125:142);%Pull out beat histogram features
    X = X(125:142, 1);
end