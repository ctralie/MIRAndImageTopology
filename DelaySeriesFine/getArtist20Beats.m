ii = 1;
alltracks = 'a20-all-tracks.txt';
files = textread(alltracks, '%s\n');
[X, Fs] = audioread(sprintf('../DelaySeries/artist20/mp3s-32k/%s.mp3', files{ii}));
ChromaFtrs = load( sprintf('../DelaySeries/artist20/chromftrs/%s.mat', files{ii}) );
bts = ChromaFtrs.bts;

%X = X(Fs:Fs*6);%Seconds 1-6

[Is, Generators, SampleDelays, Ds] = localTDABeats(X, Fs);
save(sprintf('%i.mat', ii), 'X', 'Fs', 'bts', 'Is', 'Generators', 'SampleDelays');

%Setup time loop indices
tmp = ones(length(SampleDelays{1}));
tmp = tril(tmp,-1);%Exclude the diagonal
[startV, endV] = find(tmp);%Indices of the starting and

D = Ds{100};
Delays = SampleDelays{100};
[~, idx] = sort(D);

SizeThresh = 10;
NDists = length(idx(:));
Loops = zeros(NDists, 5);

iloops = 1;
for ii = 1:length(idx)
    V1 = min(startV(idx(ii)), endV(idx(ii)));
    V2 = max(startV(idx(ii)), endV(idx(ii)));
    if (V2 - V1 + 1) < SizeThresh
        continue;
    end

    Loops(iloops, 1) = V1;
    Loops(iloops, 2) = V2;
    Loops(iloops, 3) = SampleDelays(V2) - SampleDelays(V1);

    iloops = iloops + 1;
    if iloops > NDists
        break;
    end
end

plot(Loops(:, 3));

for ii = 1:length(Ds)
    clf;
    Delays = SampleDelays{ii}/Fs;
    thesebts = bts(bts > min(Delays) & bts < max(Delays));
    [btsx, btsy] = meshgrid(thesebts, thesebts);
    imagesc(Delays, Delays, squareform(Ds{ii}));
    axis equal;
    hold on;
    plot(btsx(:), btsy(:), 'r*');
    title(sprintf('%i', ii));
    xlabel('Seconds');
    ylabel('Seconds');
    print('-dpng', '-r100', sprintf('%i.png', ii));
end