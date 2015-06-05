%Inputs: 
%S: A Nx2 array of persistence points for the first diagram
%T: A Mx2 array of persistence points for the second diagram
function [ matchidx, matchdist, D ] = getWassersteinDist( S, T )
    N = size(S, 1);
    M = size(T, 1);
    
    DUL = pdist2(S, T);
    
    %Put diagonal elements into the matrix
    %Rotate the diagrams to make it easy to find the straight line
    %distance to the diagonal
    R = [cos(pi/4) -sin(pi/4); sin(pi/4) cos(pi/4)];
    S = S*R;
    T = T*R;
    D = zeros(N+M, N+M);
    D(1:N, 1:M) = DUL;
    UR = max(D(:))*ones(N, N);
    UR(1:N+1:end) = S(:, 2);
    D(1:N, M+1:end) = UR;
    UL = max(D(:))*ones(M, M);
    UL(1:M+1:end) = T(:, 2);
    D(N+1:end, 1:M) = UL;
    
    %Make use of an externally written Hungarian algorithm file
    [matchidx, matchdist] = Hungarian(D);
end