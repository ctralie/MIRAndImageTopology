function [Chroma, SampleDelays] = makeSlidingChromaVideo( filename, NSeconds, outprefix )
    notes = {'A', 'A^#/B^b', 'B', 'C', 'C^#/D^b', 'D', 'D^#/E^b', 'E', 'F', 'F^#/G^b', 'G', 'G^#/A^b'};
    notes2 = cell(1, length(notes)*3);
    for ii = 1:length(notes2)
        notes2{ii} = '';
    end
    for ii = 1:length(notes)
        notes2{(ii-1)*3+1} = notes{ii};
    end
    notes = cell(1, length(notes2));
    for ii = 1:length(notes2)
        notes{ii} = notes2{end-ii+1};
    end
    
    [X, Fs] = audioread(filename);
    if size(X, 2) > 1
        X = mean(X, 2);
    end
    
    %Make movie
    X = X(1:Fs*NSeconds);
    [Chroma, SampleDelays] = getChromaTempoWindow({X, Fs}, 0.5);
    hopSize = SampleDelays(2) - SampleDelays(1);
    windowSize = int32(round(2/hopSize));
    SkipNum = 10;
    FramesPerSecond = 1.0/(SkipNum*hopSize)
    index = 1;
    for ii = 1:SkipNum:size(Chroma, 2)-windowSize+1
        clf;
        fprintf(1, '%i of %i\n', ii, size(Chroma, 2)-windowSize+1);
        Y = Chroma(:, ii:ii+windowSize-1)';
        C = Y';
        imagesc(SampleDelays(ii:ii+windowSize-1), 1:size(C, 1), flipud(C));
        xlabel('Time');
        ylabel('Chroma Bin');
        set(gca, 'YTick', 1:36);
        set(gca, 'YTickLabel', notes);
        title(sprintf('"%s" Chroma', outprefix));
        print('-dpng', '-r100', sprintf('syncmovie%i.png', index));
        index = index + 1;
    end
    audiowrite('syncmoviesound.wav', X, Fs);
    system(sprintf('avconv -r %g -i syncmovie%s.png -i syncmoviesound.wav -b 65536k -r 24 %sChromaVideo.ogg', ...
        FramesPerSecond, '%d', outprefix));
    system('rm syncmovie*.png');
    
    %Make loop ditty video
    Chroma = Chroma';
    Chroma = bsxfun(@minus, mean(Chroma), Chroma);
    Norm = 1./(sqrt(sum(Chroma.*Chroma, 2)));
    Chroma = Chroma.*(repmat(Norm, [1, size(Chroma, 2)]));
    [~, Chroma, latent] = pca(Chroma);
    audiowrite(sprintf('%s.ogg', outprefix), X, Fs);
    fout = fopen(sprintf('%sChroma.txt', outprefix), 'w');
    for ii = 1:size(Chroma, 1)
       fprintf(fout, '%g,%g,%g,%g,', Chroma(ii, 1), Chroma(ii, 2), Chroma(ii, 3), SampleDelays(ii)); 
    end
    fprintf(fout, '%g', sum(latent(1:3))/sum(latent));%Variance explained
    fclose(fout);    
end