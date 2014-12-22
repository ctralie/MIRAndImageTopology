function [ MaxI, SampleDelays ] = doLocalMaxPersistence( filename, hopSize, ...
    windowSize, slidingSize, outPrefix )

    skipFac = 10;
    
    init;
    [X, Fs] = audioread(filename);
    if size(X, 2) > 1
        X = sum(X, 2);
    end
    winSizeSec = hopSize/Fs;
    MFCC = melfcc(X, Fs, 'maxfreq', 8000, 'numcep', 20, 'nbands', 40, 'fbtype', 'fcmel', 'dcttype', 1, 'usecmp', 1, 'wintime', winSizeSec, 'hoptime', winSizeSec, 'preemph', 0, 'dither', 1);
    MFCC = MFCC';
    disp('Finished MFCCs');
    
    %Average MFCC windows
    N = size(MFCC, 1) - windowSize + 1;
    Y = zeros(N, size(MFCC, 2));
    AllSampleDelays = zeros(1, N);
    for ii = 1:N
        AllSampleDelays(ii) = (ii*hopSize)/Fs;
        Y(ii, :) = mean(MFCC(ii:ii+windowSize-1, :), 1);
    end
    disp('Finished average MFCCs');
    
    %TODO: Try without sphere normalization
    %Point Center and Normalize to Sphere
    Y = bsxfun(@minus, Y, mean(Y, 1));
    Y = bsxfun(@times, Y, 1./sqrt(sum(Y.*Y, 2)));
    
    %Determine indices for sliding sliding windows
    idx = 1:skipFac:size(Y, 1) - slidingSize + 1;
    MaxI = zeros(1, length(idx));
    SampleDelays = zeros(1, length(idx));
    
    for ii = 1:length(idx)
        fprintf(1, '%i of %i\n', ii, length(idx));
        SampleDelays(ii) = AllSampleDelays(idx(ii));
        I = rca1pc(Y(idx(ii):idx(ii)+slidingSize-1, :), 1e9);
        if size(I, 1) > 0
            MaxI(ii) = max(I(:, 2) - I(:, 1));
        end
    end
    
    for ii = 1:length(MaxI)
        clf;
        plot(SampleDelays, MaxI);
        hold on;
        stem(SampleDelays(ii), MaxI(ii), 'r');
        title(sprintf('%s: %g Sec', outPrefix, SampleDelays(ii)));
        xlabel('Time');
        ylabel('Max Persistence');
        print('-dpng', '-r100', sprintf('%i.png', ii));
    end
    rate = SampleDelays(2) - SampleDelays(1);
    rate = 1/rate;
    command = sprintf('avconv -r %g -i %s.png -i %s -r %g %s%i_%i.ogg', rate, '%d', filename, rate, outPrefix, windowSize, slidingSize)
    system(command);
    system('rm *.png');
    
    save(sprintf('%s%i_%i.mat', outPrefix, windowSize, slidingSize), 'MaxI', 'SampleDelays');
end