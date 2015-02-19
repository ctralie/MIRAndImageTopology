function [ MFCCs, Fs, SampleDelays, PointClouds, IsRips, IsMorse, Dists, LEigs, TimeLoopHists, bts ] = ...
    getBeatSyncShapeFeaturesChroma( tda, filename, bts, DOPLOT, BtsWin )
    
    if nargin < 4
        DOPLOT = 0;
    end    
    if nargin < 5
    	BtsWin = 2;
    end
    
    [X, Fs] = audioread(filename);
    
    if nargin < 3
        %If the beats aren't passed along, compute them now using Ellis's
        %code
        [~, bts] = chrombeatftrs(X, Fs);
    end
    [SampleDelays, Ds, PointClouds] = localChromaBeats(X, Fs, bts, BtsWin);

    %Allocate space for persistence diagrams and laplacian eigenvalues
    IsRips = cell(1, length(Ds));
    IsMorse = cell(1, length(Ds));
    LEigs = cell(1, length(Ds));
    TimeLoopHists = cell(1, length(Ds));
    Dists = zeros(length(Ds), 2);%Euclidean (column 1)/Geodesic (column 2) dists
    MFCCs = 0;
    
    for dindex = 1:length(Ds)
        D = Ds{dindex};
        D = squareform(D);
        Dists(dindex, 1) = D(1, end);%Euclidean dist
        Dists(dindex, 2) = sum(diag(D, 1));%Geodesic dist
    end
end

