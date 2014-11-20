ii = 100;
init;

alltracks = 'a20-all-tracks.txt';
files = textread(alltracks, '%s\n');
[X, Fs] = audioread(sprintf('../DelaySeries/artist20/mp3s-32k/%s.mp3', files{ii}));
ChromaFtrs = load( sprintf('../DelaySeries/artist20/chromftrs/%s.mat', files{ii}) );
bts = ChromaFtrs.bts;
meanMicroBeat = mean(bts(2:end) - bts(1:end-1));

[Is, Generators, SampleDelays, Ds] = localTDABeats(X, Fs, meanMicroBeat);

%Setup time loop indices
tmp = ones(length(SampleDelays{1}));
tmp = tril(tmp,-1);%Exclude the diagonal
[startV, endV] = find(tmp);%Indices of the starting and

for dindex = 1:length(Ds)
    clf;
    
    D = Ds{dindex};
    Delays = SampleDelays{dindex};
    [DSorted, idx] = sort(D);
    
    D = squareform(D);
    N = size(D, 1);
    NNeighbs = round(0.1*N*N)%Top 10% of neighbors
    LoopTimes = zeros(1, NNeighbs);
    A = zeros(size(D));%Adjacency matrix

    NDists = length(idx(:));

    iloops = 1;
    for ii = 1:NNeighbs
        V1 = min(startV(idx(ii)), endV(idx(ii)));
        V2 = max(startV(idx(ii)), endV(idx(ii)));

        LoopTimes(iloops) = (SampleDelays{dindex}(V2) - SampleDelays{dindex}(V1))/Fs;
        A(V1, V2) = DSorted(ii);
        A(V2, V1) = DSorted(ii);
        
        iloops = iloops + 1;
        if iloops > NDists
            break;
        end
    end
    %Construct weighted graph laplacian
    Deg = A;
    Deg(1:N+1:end) = 0;
    DegDiag = (A > 0 | eye(N)).*diag(sum(Deg, 1));
    %Uncomment for normalized
    %DegSqrtInv = (A > 0 | eye(N)).*diag(1./sqrt(sum(Deg, 1)));
    %L = DegDiag - (DegSqrtInv)*A*(DegSqrtInv);
    L = DegDiag - A;
    e = eig(L);
    subplot(2, 3, 4);
    plot(e);
    ylim([0, 60]);
    xlabel('Eigenvalue Number');
    ylabel('Value');
    title('Laplacian Eigenvalues');
    
    Delays = SampleDelays{dindex}/Fs;
    thesebts = bts(bts > min(Delays) & bts < max(Delays));
    [btsx, btsy] = meshgrid(thesebts, thesebts);
    
    thesebts = thesebts(2:end) - thesebts(1:end-1);
    subplot(2, 3, 5:6);
    hist(LoopTimes, 30);
    hold on;
    plot(thesebts, 50*ones(1, length(thesebts)), 'r.');
    plot(thesebts*2, 50*ones(1, length(thesebts)), 'r*');
    plot(thesebts*3, 50*ones(1, length(thesebts)), 'ro');
    plot(thesebts*4, 50*ones(1, length(thesebts)), 'rx');

    xlabel('Time Loop Interval (Seconds)');
    ylabel('Count');
    title('Time Loop Interval Histogram');
    
    subplot(2, 3, 2);
    imagesc(Delays, Delays, L);
    axis equal;
    ylim([min(Delays), max(Delays)]);
    title('Graph Laplacian');
    xlabel('Seconds');
    ylabel('Seconds');
    
    subplot(2, 3, 1);
    imagesc(Delays, Delays, D);
    axis equal;
    hold on;
    plot(btsx(:), btsy(:), 'r*');
    title(sprintf('Distance Matrix (%.3g - %.3g Secs)',  ...
        SampleDelays{dindex}(1)/Fs, SampleDelays{dindex}(end)/Fs));
    xlabel('Seconds');
    ylabel('Seconds');
    ylim([min(Delays), max(Delays)]);
    
    I = rca1dm(D, max(D(:)));
    subplot(2, 3, 3);
    if ~isempty(I)
        plotpersistencediagram(I);
    end
    
    xlabel('Birth Time');
    ylabel('Death Time');
    title('Persistence Diagram');
    
    print('-dsvg', '-r150', sprintf('%i.svg', dindex));
    print('-dpng', '-r100', sprintf('%i.png', dindex));
end