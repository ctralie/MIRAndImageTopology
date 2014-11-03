%Programmer: Chris Tralie
%Purpose: Starting with a path through time, to add exactly one edge to the
%path based on the proximity in the feature space, and to compute
%statistics on the resulting loop (then to remove this edge and repeat)

%Inputs:
%idx: Index of the song in a20-all-trakcs.list
%windowSize: The size of the sliding window (in seconds) taking the
%mean/std of MFCC
%SizeThresh: Don't consider loops with number of edges fewer than "SizeThresh"
%DownsampleFac: The factor by which to downsample the curve to speed up
%computation (10 by default)
%NDists: The closest "NDists" edges will all be examined.  If this argument
%is omitted, all distances will be examined

%Outputs:
%Loops: An NDists x 5 Array, where each loop each loop is described by
    %1-2: starting and ending vertices in time
    %3: Length (start - end + 1)
    %4: Distance between endpoints
    %5: Arc length of loop in feature space
%Y: The Delay Series (scaled by mean/stdev)
function [Loops, Y] = getSongTimeLoops( idx, windowSize, SizeThresh, DownsampleFac, NDists )
    alltracks = '../lists/a20-all-tracks.list';
    files = textread(alltracks, '%s\n');
    if (nargin < 4)
        DownsampleFac = 10;
    end
    [Y, analysisWinSize] = getSongPointCloud(files{idx}, windowSize, DownsampleFac);
    Y = bsxfun(@minus, mean(Y, 1), Y);
    Y = bsxfun(@times, 1./std(Y), Y);
    
    %http://stackoverflow.com/questions/2476943/matlab-pdist-function
    D = pdist(Y);
    tmp = ones(size(Y, 1));
    tmp = tril(tmp,-1);%Exclude the diagonal
    [startV, endV] = find(tmp);%Indices of the starting and
    %terminating vertices
    
    [~, idx] = sort(D);
    if nargin < 5
        NDists = length(idx);
    end    
    Loops = zeros(NDists, 5);
    
    iloops = 1;
    for ii = 1:length(idx)
        if mod(ii, 20000) == 0
           fprintf(1, '.'); 
        end
        if mod(ii, 1000000) == 0
           fprintf(1, '\n');
        end
        V1 = min(startV(idx(ii)), endV(idx(ii)));
        V2 = max(startV(idx(ii)), endV(idx(ii)));
        if (V2 - V1 + 1) < SizeThresh
            continue;
        end
        
        Loops(iloops, 1) = V1;
        Loops(iloops, 2) = V2;
        Loops(iloops, 3) = V2 - V1 + 1;
        
        Loop1 = Y(V1:V2, :);
        Loop2 = [Y(V1+1:V2, :); Y(V1, :)];
        Len = Loop2 - Loop1;
        Len = sum(sqrt(sum(Len.*Len, 2)));
        Loops(iloops, 4) = D(idx(ii));
        Loops(iloops, 5) = Len;
        
        iloops = iloops + 1;
        if iloops > NDists
            break;
        end
    end
    
    %Cut off extra entries if they are zero
    if iloops < size(Loops, 1)
        Loops = Loops(1:iloops-1, :);
    end
end

