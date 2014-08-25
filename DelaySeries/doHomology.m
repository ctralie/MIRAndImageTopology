%timeReg: A variable that controls "time regularization"; or the scale of
%an extra dimension which indicates where a delay series sample is in time
function [I, J, JGenerators] = doHomology( filename,  hopSize, skipSize, windowSize, timeReg )
    addpath('../TDAMex');
    [DelaySeries, Fs, SampleDelays] = getDelaySeriesFeatures( filename, hopSize, skipSize, windowSize );
    SampleDelays = SampleDelays / Fs;
    fprintf(1, 'Finished computing delay series with %i samples\n', length(SampleDelays));
    
    maxTime = 60;
    %Only look at the first 10 seconds
    
    lastIdx = length(SampleDelays);%sum(SampleDelays < maxTime)
    DelaySeries = DelaySeries(1:lastIdx, :);
    SampleDelays = SampleDelays(1:lastIdx, :);
    
    %Normalize data to the range [0, 1] in each dimension
    minData = min(DelaySeries);
    DelaySeries = bsxfun(@minus, DelaySeries, minData);
    maxData = max(DelaySeries);
    DelaySeries = bsxfun(@times, DelaySeries, 1./(maxData+eps));
    
    %Add the extra time dimension
    DelaySeries = [DelaySeries timeReg*SampleDelays(:)];
    size(DelaySeries)
    
    %Calculate the distance matrix
    disp('Calculating distance matrix...');
    D = squareform(pdist(DelaySeries));
    minDist = min(D(:));
    maxDist = max(D(:));
    maxEdgeLength = 0.5*maxDist;
    disp('Finished calculating distance matrix');
    disp('Beginning to get persistence points and generators...');
    [I, J, JGenerators] = getGeneratorsFromTDAJar(D, maxEdgeLength);
    disp('Finished getting persistence points and generators.');
    plotPersistenceDiagrams(I, J, minDist, maxDist);
    [~, genOrder] = sort(J(:, 2) - J(:, 1), 'descend');%Sort the points in
    %decreasing order of persistece
    %[~, genOrder] = sort(J(:, 1), 'ascend');%Sort the points in increasing order of birth time
    %[~, genOrder] = sort(J(:, 2), 'descend');%Sort the points in decreasing order of death time
    dimx = 5;
    figure;
    %Plot the seconds where different samples occur, and save audio files
    [Y, Fs] = audioread(filename);
    if size(Y, 2) > 1
       %Merge to mono if there is more than one channel
       Y = sum(Y, 2)/size(Y, 2); 
    end
    for ii = 1:dimx*dimx
       %Make the plot
       subplot(dimx, dimx, ii);
       thisGenerator = JGenerators{genOrder(ii)};
       plot(SampleDelays(thisGenerator));
       xlabel('Sample Number');
       ylabel('Seconds');
       title( sprintf('%g', J(genOrder(ii), 2) - J(genOrder(ii), 1)) );
       %Save audio files
       X = [];
       for jj = 1:length(thisGenerator)
           i1 = 1 + (thisGenerator(jj)-1)*hopSize*skipSize;
           i2 = i1 + hopSize*windowSize - 1;
           X = [X; Y(i1:i2)];
       end
       audiowrite(sprintf('%i.ogg', ii), X, Fs);
    end
    figure;
    for ii = 1:dimx*dimx
       %Make the plot
       subplot(dimx, dimx, ii);
       thisGenerator = JGenerators{genOrder(ii)};
       plot(SampleDelays(sort(thisGenerator)));
       xlabel('Sample Number');
       ylabel('Seconds');
       title( sprintf('%g', J(genOrder(ii), 2) - J(genOrder(ii), 1)) );
       %Save audio files
       mask = zeros(size(Y));
       for jj = 1:length(thisGenerator)
           i1 = 1 + (thisGenerator(jj)-1)*hopSize*skipSize;
           i2 = i1 + hopSize*windowSize - 1;
           mask(i1:i2) = 1;
       end
       X = Y(mask == 1);
       audiowrite(sprintf('%iSorted.ogg', ii), X, Fs);
    end
end