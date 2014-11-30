%Compute the beat-synchronous TDA, and also compute many 30ms MFCCs

javaclasspath('jars/tda.jar');
import api.*;
tda = Tda();

genres = {'blues', 'classical', 'country', 'disco', 'hiphop', 'jazz', 'metal', 'pop', 'reggae', 'rock'};
DOPLOT = 1;

try
    genreIdx = ceil(songindex/100);
    songIdx = mod(songindex, 100);
    genre = genres{genreIdx};
    filename = sprintf('genres/%s/%s.%.5i.au', genre, genre, songIdx);
    beatsFilename = sprintf('genres/%s/%s.%.5i.mat', genre, genre, songIdx);
    fprintf(1, 'Doing %s song %i...\n', genre, songIdx);
    
    [X, Fs] = audioread(filename);

    %Step 1: Compute small chunk MFCCs
    winSizeSec = 0.03;
    MFCCs = melfcc(X, Fs, 'maxfreq', 8000, 'numcep', 20, 'nbands', 40, 'fbtype', 'fcmel', 'dcttype', 1, 'usecmp', 1, 'wintime', winSizeSec, 'hoptime', winSizeSec, 'preemph', 0, 'dither', 1);    
        
    %Step 2: Compute beat-synchronous TDA
    %Precomputed macrobeats
    bts = load(beatsFilename);
    bts = bts.onsets;
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
        
        if DOPLOT == 1
            clf;
            subplot(2, 3, 3);
            I = Is{dindex};
            if ~isempty(I)
                plot(I(:, 1), I(:, 2), 'b.');
                hold on;
                plot([0, max(I(:))], [0, max(I(:))], 'r');
                axis equal;
            end
            
            subplot(2, 3, 4);
            plot(LEigs{dindex});
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
            print('-dpng', '-r100', sprintf('%i.png', dindex));
        end
        
    end
    save(sprintf('genres/%s/%s.%.5iBeatSync.mat', genre, genre, songIdx),  ...
        'LEigs', 'Is', 'bts', 'SampleDelays', 'Fs', 'TimeLoopHists', 'MFCCs');
catch err
    err
end
