javaclasspath('jars/tda.jar');
import api.*;
tda = Tda();

try
    alltracks = 'a20-all-tracks.txt';
    files = textread(alltracks, '%s\n');
    fprintf(1, 'PROCESSING SONG: %s\n', files{songindex});
    [X, Fs] = audioread(sprintf('BeatsAndOggs/%i.ogg', songindex));

    %Precomputed microbeat
    load(sprintf('BeatsAndOggs/%i.mat', songindex));
    [SampleDelays, Ds] = localTDABeats(X, Fs, bts);

    %Setup time loop indices
    tmp = ones(length(SampleDelays{1}));
    tmp = tril(tmp,-1);%Exclude the diagonal
    [startV, endV] = find(tmp);%Indices of the starting and

    %Allocate space for persistence diagrams and laplacian eigenvalues
    Is = cell(1, length(Ds));
    LEigs = cell(1, length(Ds));
    TimeLoopHists = cell(1, length(Ds));
    
    for dindex = 1:length(Ds)
        D = Ds{dindex};
        Delays = SampleDelays{dindex};
        [DSorted, idx] = sort(D);

        D = squareform(D);
        N = size(D, 1);
        NNeighbs = round(0.1*N*N);%Top 10% of neighbors
        LoopTimes = zeros(1, NNeighbs);
        A = zeros(size(D));%Adjacency matrix

        NDists = length(idx(:));

        iloops = 1;
        for ii = 1:NNeighbs
            V1 = min(startV(idx(ii)), endV(idx(ii)));
            V2 = max(startV(idx(ii)), endV(idx(ii)));

            LoopTimes(iloops) = V2 - V1;
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

        %Save graph laplacian eigenvalues
        LEigs{dindex} = eig(L);
        
        %Save DGM1
        tda.RCA1( { 'settingsFile=data/cts.txt', 'supplyDataAs=distanceMatrix', ...
            sprintf('distanceBoundOnEdges=%g', max(D(:)) + 10)}, D );
        Is{dindex} = tda.getResultsRCA1(1).getIntervals();
        
        %Save time loop histogram
        TimeLoopHists{dindex} = hist(LoopTimes, linspace(0, N, N/5+1));
    end
    save(sprintf('BeatSync%i.mat', songindex), 'LEigs', 'Is', 'bts', 'SampleDelays', 'Fs', 'meanMicroBeat', 'TimeLoopHists');
catch err
    err
end
