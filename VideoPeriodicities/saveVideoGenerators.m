function [] = saveVideoGenerators( filename, J, JGenerators, NGenerators, D, tolerance )
    addpath('../TDAMex');
    if nargin < 6
       tolerance = 2; 
    end
    [JOut, JGeneratorsOut] = getContinuousGenerators(J, JGenerators, tolerance);
    fprintf(1, 'There are %i continuous generators\n', length(JGeneratorsOut));
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
           thisFrame = Generator(jj);
           %Plot the frame position up top
           frameim = zeros(20, size(D, 1));
           frameim(:, Generator) = 1;
           frameim(:, max(thisFrame-2, 1):min(thisFrame+2, end)) = 2;
           subplot(20, 20, [1:20]);
           imagesc(frameim);
           title(sprintf('Cycle %i Frame %i', ii, thisFrame));
           axis equal;
           
           %Now plot the frame next to the MDS projected position
           frame = read(videoReader, thisFrame);
           writeVideo(writerObj, frame);
           x = 21:400;
           x = x(mod(ceil(x/10), 2) == 0);
           subplot(20, 20, x);
           imagesc(frame);
           axis equal;axis square;
           x = 21:400;
           x = x(mod(ceil(x/10), 2) == 1);
           subplot(20, 20, x);
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