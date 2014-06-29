function [] = saveVideoGenerators( filename, outPrefix, J, JGenerators, NGenerators, D, tolerance )
    addpath('../TDAMex');
    if nargin < 7
       tolerance = 2; 
    end
    [JOut, JGeneratorsOut] = getContinuousGenerators(J, JGenerators, tolerance);
    fprintf(1, 'There are %i continuous generators\n', length(JGeneratorsOut));
    lengths = zeros(1, length(JGeneratorsOut));
    for ii = 1:length(lengths)
       lengths(ii) = length(JGeneratorsOut{ii}); 
    end
    [~, genOrder] = sort(JOut(:, 2) - JOut(:, 1), 'descend');%Sort by persistence
    %[~, genOrder] = sort(lengths, 'descend');
    videoReader = VideoReader(filename);
    frameIndex = 0;
    for ii = 1:min(length(genOrder), NGenerators)
        thisFilename = sprintf('%s%i.avi', outPrefix, ii);
        writerObj = VideoWriter(thisFilename);
        open(writerObj);
        Generator = JGeneratorsOut{genOrder(ii)};
        for jj = 1:length(Generator)
           clf;
           thisFrame = Generator(jj);
           %Plot the frame position up top
           frameim = zeros(20, size(D, 1));
           frameim(:, Generator) = 1;
           frameim(:, max(thisFrame-2, 1):min(thisFrame+2, end)) = 2;
           subplot(10, 10, [1:5]);
           imagesc(frameim);
           persistence = JOut(genOrder(ii), 2) - JOut(genOrder(ii), 1);
           title(sprintf('Cycle %i Frame %i Persistence %g', ii, thisFrame, persistence));
           axis equal;
           
           %Plot the frame locations of the generator, along with
           %a stem for the current frame
           subplot(10, 10, [6:10]);
           plot(Generator);
           hold on;
           stem(jj, thisFrame, 'r');
           ylim([min(Generator), max(Generator)]);
           
           %Now plot the frame next to the MDS projected position
           frame = read(videoReader, thisFrame);
           writeVideo(writerObj, frame);
           x = 11:100;
           x = x(mod(ceil(x/5), 2) == 0);
           subplot(10, 10, x);
           imagesc(frame);
           axis equal;axis square;
           x = 11:100;
           x = x(mod(ceil(x/5), 2) == 1);
           subplot(10, 10, x);
           Y = cmdscale(D(Generator, Generator));
           scatter(Y(:, 1), Y(:, 2), 50, 'b', 'fill');
           hold on;
           plot([Y(:, 1); Y(1, 1)], [Y(:, 2); Y(1, 2)]);
           scatter(Y(jj, 1), Y(jj, 2), 50, 'r', 'fill');
           axis equal;axis square;
           
           print('-dpng', '-r100', sprintf('%s%i.png', outPrefix, frameIndex));
           frameIndex = frameIndex + 1;
        end
        clf;
        close(writerObj);
    end
    system(sprintf('ffmpeg -r 4 -i %s%s.png -r 4 %s.ogg', outPrefix, '%d', outPrefix));
    system('rm %s*.png', outPrefix);
end