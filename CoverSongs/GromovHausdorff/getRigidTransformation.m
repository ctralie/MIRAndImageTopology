%Helper function for ICP
function [ T ] = getRigidTransformation( Points, TargetPoints )
    dim = size(Points, 2);
    meanP = mean(Points, 1);
    meanT = mean(TargetPoints, 1);
    P = bsxfun(@minus, meanP, Points);
    T = bsxfun(@minus, meanT, TargetPoints);
    H = P'*T;
    [U, ~, V] = svd(H);
    R = eye(dim+1);
    R(1:dim, 1:dim) = V'*U';
    %Transformation order:
    %1: Move the point set so it's centered on the centroid
    %2: Rotate the point set by the calculated rotation
    %3: Move the point set so it's centered on the target centroid
    T1 = eye(dim+1);
    T1(1:dim, end) = -meanP';
    T2 = eye(dim+1);
    T2(1:dim, end) = meanT;
    %In other words, T2*R*T1
    T = T2*R*T1;
end

