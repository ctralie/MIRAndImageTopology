function [dist] = getEarthMovers( I1, I2 )
    N = size(I1, 1);
    M = size(I1, 2);
    dist = inf;
    if N ~= size(I2, 1) || M ~= size(I2, 2)
        disp('Error: Images must be same size');
        return;
    end
    [X, Y] = meshgrid(1:N, 1:M);
    Pos = [X(:) Y(:)];
    dist = histStatsEMD(I1(:), Pos, I2(:), Pos);
end