alltracks = '../lists/a20-all-tracks.list';
files = textread(alltracks, '%s\n');

songIndex = 1;%Aerosmith's first song
windowSize = 3;
SizeThresh = 1;
DownsampleFac = 10;
NPoints = 10000;
[Loops, DelaySeries] = getSongTimeLoops(songIndex, windowSize, SizeThresh, DownsampleFac, NPoints);%Aerosmith's first song

MFCCSAMPLELEN = 0.016;
hopSize = MFCCSAMPLELEN * DownsampleFac;
SampleDelays = hopSize*(0:size(DelaySeries, 1)-1);
Loops(:, 3) = Loops(:, 3)*hopSize;%Convert into seconds

plot(Loops(:, 4), Loops(:, 3));
xlabel('Endpoint Distance');
ylabel('Length of Loop (Seconds)');
title('Closest Pairs Time Loops');

figure;
plot(Loops(:, 3), Loops(:, 5), '.');
xlabel('Length of Loop (Seconds)');
ylabel('Arc Length in Feature Space');
title('Arc Length vs Time Length');

%Now export the first big loop into LoopDitty
BigLoops = Loops( logical((Loops(:, 3) > 20) .* (Loops(:, 3) < 50)), :);
[~, DelaySeries, latent] = pca(DelaySeries);
clipRange = BigLoops(1, 1):BigLoops(1, 2);
DelaySeries = DelaySeries(clipRange, 1:3);
SampleDelays = SampleDelays(clipRange);

[soundSamples, Fs] = audioread(sprintf('../mp3s-32k/%s.mp3', files{songIndex}));
startidx = round(SampleDelays(1)*Fs);
endidx = round(SampleDelays(end)*Fs);
soundSamples = soundSamples(startidx:endidx);
audiowrite('loopclip.ogg', soundSamples, Fs);

SampleDelays = SampleDelays - SampleDelays(1);

fout = fopen('loopclip.txt', 'w');
for ii = 1:size(DelaySeries, 1)
   fprintf(fout, '%g,%g,%g,%g,', DelaySeries(ii, 1), DelaySeries(ii, 2), DelaySeries(ii, 3), SampleDelays(ii)); 
end
fprintf(fout, '%g', sum(latent(1:3))/sum(latent));%Variance explained
fclose(fout);