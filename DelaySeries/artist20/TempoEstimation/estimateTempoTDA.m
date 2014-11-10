function [tempos, TDAScores, TDAScoresMean, GTTempo] = estimateTempoTDA( fileprefix )
    init;%Initialize TDA tools
    addpath('../../');
    addpath('../../chroma-ansyn');
    addpath('../../rastmat');
    filename = sprintf('../mp3s-32k/%s.mp3', fileprefix);
    chromftrs = load(sprintf('../chromftrs/%s.mat', fileprefix));
    bts = chromftrs.bts;%Ground truth tempo info
    %Throw the ground truth in (throw in 2x since the "tatums" seem to be
    %the microbeat)
    macrobeat = 2*mean(bts(2:end) - bts(1:end-1));
    GTTempo = 60.0/macrobeat;
    
    origTempos = GTTempo/2-20:10:GTTempo*1.5+10;
    
    length(origTempos)
    
    fprintf(1, 'Doing %s, macrobeat: %g\n', fileprefix, GTTempo);
    
    Fs = 16000;%Sampling rate of all songs in the artist20 dataset
    hopSize = 2*Fs/100;%Jump every 20ms
    skipSize = 1;
    NMFCCs = 20;
    
    tempos = zeros(1, length(origTempos));
    TDAScores = cell(1, length(origTempos));
    
    for ii = 1:length(origTempos)
        windowSize = round((60/origTempos(ii))/(hopSize/Fs));
        tempos(ii) = 60.0/(windowSize*hopSize/Fs);%Actual tempo after rounding
        fprintf(1, 'origtempo = %g, tempoWin = %g, tempo = %g, windowSize = %i\n', origTempos(ii), ...
            windowSize*hopSize/Fs, tempos(ii), windowSize); 
        
        X = getDelaySeriesFeatures( filename, hopSize, skipSize, windowSize, NMFCCs );
        %Use only MFCC means
        X = X(:, 5:24);
        
        %Advance by one window and take 3 windows at a time
        idx = 1:windowSize:size(X, 1)-2*windowSize;
        maxps = zeros(1, length(idx));
        for kk = 1:length(idx)
            Y = X(idx(kk):idx(kk)+2*windowSize-1, :);
            Y = scaleAndMeanShift(Y);
            I = rca1pc(Y, 1000);
            if ~isempty(I)
                maxps(kk) = max(I(:, 2) - I(:, 1));
            end
        end
        TDAScores{ii} = maxps;
    end
    
    TDAScoresMean = zeros(length(TDAScores), 1);
    for ii = 1:length(TDAScores)
        S = TDAScores{ii};
        S = S(S > 0);
        TDAScoresMean(ii) = mean(S);
    end
end