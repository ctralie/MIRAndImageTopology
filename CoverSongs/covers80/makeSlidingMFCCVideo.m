function [] = makeSlidingMFCCVideo( X, Fs, NSeconds, outprefix )
    %Make movie
    X = X(1:Fs*NSeconds);
    [AllSampleDelays, ~, PointClouds] = localMFCCBeats(X, Fs, 0:0.5:NSeconds, 20, 1);
    SampleDelays = cell2mat(AllSampleDelays)/Fs;
    MFCCs = cell2mat(PointClouds');
    
    hopSize = SampleDelays(2) - SampleDelays(1);
    windowSize = int32(round(2/hopSize));%2 seconds are in view at all times
    SkipNum = 10;
    FramesPerSecond = 1.0/(SkipNum*hopSize)
    index = 1;
    for ii = 1:SkipNum:size(MFCCs, 1)-windowSize+1
        clf;
        fprintf(1, '%i of %i\n', ii, size(MFCCs, 1)-windowSize+1);
        Y = MFCCs(ii:ii+windowSize-1, :)';
        imagesc(SampleDelays(ii:ii+windowSize-1), 1:size(Y, 2), Y);
        title(sprintf('"%s" MFCC', outprefix));
        xlabel('Time');
        ylabel('MFCC Bin');
        print('-dpng', '-r100', sprintf('syncmovie%i.png', index));
        index = index + 1;
    end
    audiowrite('syncmoviesound.wav', X, Fs);
    system(sprintf('avconv -r %g -i syncmovie%s.png -i syncmoviesound.wav -b 65536k -r 24 %sMFCCVideo.ogg', ...
        FramesPerSecond, '%d', outprefix));
    system('rm syncmovie*.png');
    
    %Make loop ditty video
    MFCCs = bsxfun(@minus, mean(MFCCs), MFCCs);
    Norm = 1./(sqrt(sum(MFCCs.*MFCCs, 2)));
    MFCCs = MFCCs.*(repmat(Norm, [1, size(MFCCs, 2)]));
    [~, Y, latent] = pca(MFCCs);
    audiowrite(sprintf('%s.ogg', outprefix), X, Fs);
    fout = fopen(sprintf('%sMFCC.txt', outprefix), 'w');
    for ii = 1:size(Y, 1)
       fprintf(fout, '%g,%g,%g,%g,', Y(ii, 1), Y(ii, 2), Y(ii, 3), SampleDelays(ii)); 
    end
    fprintf(fout, '%g', sum(latent(1:3))/sum(latent));%Variance explained
    fclose(fout);    
end