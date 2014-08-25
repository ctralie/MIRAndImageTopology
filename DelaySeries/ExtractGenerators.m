filename = 'WangChung';
% hopSize = 2048;
% skipSize = 1;
% windowSize = 10;
hopSize = 44100;
skipSize = 1;
windowSize = 10;
[I, J, JGenerators] = doHomology( sprintf('%s.wma', filename),  hopSize, skipSize, windowSize );
[~, genRange] = sort(J(:, 2) - J(:, 1), 'descend');

for ii = 1:length(JGenerators) 
    idx = JGenerators{genRange(ii)};
    [X, Fs] = getMusicParts( sprintf('%s.wma', filename), idx, hopSize, skipSize, windowSize);
    audiowrite(sprintf('%s%i.ogg', filename, ii), X, Fs);
    plot(X);
end