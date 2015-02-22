%Delta: The size of the neighborhood to consider on each side of each
%point
function [ Curv, ContigDists, SkipDists ] = getSongApproxCurvature( MFCC, Delta )
    addpath('../../');
    
    %TODO: Experiment with different types of scalings and distances
    X = bsxfun(@minus, MFCC, mean(MFCC, 1));
    X = bsxfun(@times, X, 1.0./sqrt(sum(X.*X, 2)));
    
    N = size(X, 1) - 2*Delta;
    %Compute euclidean distance of every contiguous line segment in time
    ContigDists = X(2:end, :) - X(1:end-1, :);
    ContigDists = sqrt(sum(ContigDists.*ContigDists, 2));
    ContigDists = conv(ContigDists, ones(1, 2*Delta), 'valid');
    
    %Compute the euclidean distance between the endpoints of every length
    %2*Delta + 1 path
    SkipDists = X(2*Delta+1:end, :) - X(1:end-2*Delta, :);
    SkipDists = sqrt(sum(SkipDists.*SkipDists, 2));
    
    Curv = ContigDists./SkipDists;
    Curv(isnan(Curv)) = 0;
end