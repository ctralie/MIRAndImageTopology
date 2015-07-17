function [X, SampleDelays] = getDelaySeriesJavascriptPCA(filename, tempoWindow, SamplesPerWindow, outprefix )
    [X, SampleDelays] = getMFCCTempoWindow(filename, tempoWindow, SamplesPerWindow);
    X = bsxfun(@minus, mean(X), X);
    X = bsxfun(@times, 1./sqrt(sum(X.^2, 2)), X);
    N = size(X, 1);
    [~, Y, latent] = pca(X);
    
    readSuccess = 0;
    while readSuccess == 0
        try
            [X, Fs] = audioread(filename);
            readSuccess = 1;
        catch
            readSuccess = 0;
        end
    end
    
    audiowrite(sprintf('%s.ogg', outprefix), X, Fs);
    fout = fopen(sprintf('%s.txt', outprefix), 'w');
    for ii = 1:N
       fprintf(fout, '%g,%g,%g,%g,', Y(ii, 1), Y(ii, 2), Y(ii, 3), SampleDelays(ii)); 
    end
    fprintf(fout, '%g', sum(latent(1:3))/sum(latent));%Variance explained
    fclose(fout);
end
