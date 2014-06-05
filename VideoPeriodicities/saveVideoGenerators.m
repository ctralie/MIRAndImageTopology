function [] = saveVideoGenerators( filename, J, JGenerators, NGenerators, D )
    addpath('../TDAMex');
    [JOut, JGeneratorsOut] = getContinuousGenerators(J, JGenerators, 2);
    fprintf(1, 'There are %i continuous generators\n', length(JGenerators));
    lengths = zeros(1, length(JGeneratorsOut));
    for ii = 1:length(lengths)
       lengths(ii) = length(JGeneratorsOut{ii}); 
    end
    %[~, genOrder] = sort(JOut(:, 2) - JOut(:, 1), 'descend');%Sort by persistence
    [~, genOrder] = sort(lengths, 'descend');
    videoReader = VideoReader(filename);
    frameIndex = 0;
    for ii = 1:min(length(genOrder), NGenerators)
        thisFilename = sprintf('%s%i.avi', filename, ii);
        writerObj = VideoWriter(thisFilename);
        open(writerObj);
        Generator = JGeneratorsOut{genOrder(ii)};
        for jj = 1:length(Generator)
           frame = read(videoReader, Generator(jj));
           writeVideo(writerObj, frame);
           subplot(1, 2, 1);
           imagesc(frame);
           axis equal;axis square;
           subplot(1, 2, 2);
           Y = cmdscale(D(Generator, Generator));
           scatter(Y(:, 1), Y(:, 2), 50, 'b', 'fill');
           hold on;
           plot([Y(:, 1); Y(1, 1)], [Y(:, 2); Y(1, 2)]);
           scatter(Y(jj, 1), Y(jj, 2), 50, 'r', 'fill');
           axis equal;axis square;
           
           print('-dpng', '-r100', sprintf('%i.png', frameIndex));
           frameIndex = frameIndex + 1;
        end
        clf;
        close(writerObj)
    end
end