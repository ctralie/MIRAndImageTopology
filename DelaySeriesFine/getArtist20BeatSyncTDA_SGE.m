init;

try
    disp(files{songindex});
    alltracks = 'a20-all-tracks.txt';
    files = textread(alltracks, '%s\n');
%     [X, Fs] = audioread(sprintf('../DelaySeries/artist20/mp3s-32k/%s.mp3', files{songindex}));
%     ChromaFtrs = load( sprintf('../DelaySeries/artist20/chromftrs/%s.mat', files{songindex}) );
%     
%     bts = ChromaFtrs.bts;
%     meanMicroBeat = mean(bts(2:end) - bts(1:end-1));

    %Precomputed delay series and microbeat
    load(sprintf('BeatSyncMFCCs/%i.mat', songindex));
    [~, ~, SampleDelays, Ds] = localTDABeats([], [], meanMicroBeat, DelaySeries, SampleDelays);

    %Setup time loop indices
    tmp = ones(length(SampleDelays{1}));
    tmp = tril(tmp,-1);%Exclude the diagonal
    [startV, endV] = find(tmp);%Indices of the starting and

    %Allocate space for persistence diagrams and laplacian eigenvalues
    Is = cell(1, length(Ds));
    LEigs = cell(1, length(Ds));

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

        LEigs{dindex} = eig(L);
        Is{dindex} = rca1dm(D, max(D(:)));
    end
    save(sprintf('BeatSync%i.mat', songindex), 'LEigs', 'Is', 'bts', 'SampleDelays', 'Fs', 'meanMicroBeat');
catch err
    err;
end