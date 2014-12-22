function [DelaySeriesOrig, DelaySeries, D] = getDelaySeriesJavascriptPCA( ...
    filename, hopSize, skipSize, windowSize, ...
    NMFCCs, velocityLambda, outprefix, sphereNormalize, onlyMFCCs, differential )
    if nargin < 8
    	sphereNormalize = 0;
    end
    if nargin < 9
        onlyMFCCs = 0;
    end
    if nargin < 10
        differential = 0;
    end
    [DelaySeries, ~, SampleDelays] = getDelaySeriesFeatures( filename, hopSize, skipSize, windowSize, NMFCCs );
    
    if onlyMFCCs
        DelaySeries = DelaySeries(:, 5:5+NMFCCs-1);%Only take MFCCs average
    end
    
    if differential
        DelaySeries = DelaySeries(2:end, :) - DelaySeries(1:end-1, :);
        SampleDelays = SampleDelays(1:end-1);
    end
    
    %Center on mean and scale by the standard deviation of each feature
    DelaySeries = bsxfun(@minus, mean(DelaySeries), DelaySeries);
    N = size(DelaySeries, 1);
    
    if sphereNormalize
        %Do what's done in the Sw1pers paper
        Norm = 1./(sqrt(sum(DelaySeries.*DelaySeries, 2)));
        DelaySeries = DelaySeries.*(repmat(Norm, [1 size(DelaySeries, 2)]));
    else
        DelaySeries = bsxfun(@times, 1./std(DelaySeries), DelaySeries);
    end
    
    DelaySeriesOrig = DelaySeries;
    
    if velocityLambda == 0
        [~, DelaySeries, latent] = pca(DelaySeries);
        D = 0;
    else
        %Compute velocity at each point and weight metric
        diff = DelaySeries(2:end, :) - DelaySeries(1:end-1, :);
        diff = sqrt(sum(diff.*diff, 2));
        diff = [diff; 0];
    
        D = squareform(pdist(DelaySeries)) + ...
            velocityLambda*repmat(diff, [1, N]) + ...
            velocityLambda*repmat(diff', [N, 1]);
        D(1:N+1:end) = 0;
        [DelaySeries, latent] = cmdscale(D);
    end

    readSuccess = 0;
    while readSuccess == 0
        try
            [X, Fs] = audioread(filename);
            readSuccess = 1;
        catch
            readSuccess = 0;
        end
    end    
    
    SampleDelays = SampleDelays/Fs;
    audiowrite(sprintf('%s.ogg', outprefix), X, Fs);
    fout = fopen(sprintf('%s.txt', outprefix), 'w');
    for ii = 1:N
       fprintf(fout, '%g,%g,%g,%g,', DelaySeries(ii, 1), DelaySeries(ii, 2), DelaySeries(ii, 3), SampleDelays(ii)); 
    end
    fprintf(fout, '%g', sum(latent(1:3))/sum(latent));%Variance explained
    fclose(fout);
end
