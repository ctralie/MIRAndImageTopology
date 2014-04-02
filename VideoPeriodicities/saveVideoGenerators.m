function [] = saveVideoGenerators( filename, J, JGenerators, NGenerators )
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
    for ii = 1:min(length(genOrder), NGenerators)
        thisFilename = sprintf('%s%i.avi', filename, ii);
        writerObj = VideoWriter(thisFilename);
        open(writerObj);
        Generator = JGeneratorsOut{genOrder(ii)};
        for jj = 1:length(Generator)
           frame = read(videoReader, Generator(jj));
           writeVideo(writerObj, frame);
        end
        close(writerObj)
    end
end