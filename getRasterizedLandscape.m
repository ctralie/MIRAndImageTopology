function [L] = getRasterizedLandscape( I, xrange, yrange, UpFac )
    if nargin < 4
        UpFac = 10;
    end
    if isempty(I)
        %Take care of the case of an empty persistence diagram
        L = zeros(length(yrange), length(xrange));
        return;
    end
    NX = length(xrange);
    NY = length(yrange);
    %Rasterize on a finer grid and downsample
    NXFine = UpFac*NX;
    NYFine = UpFac*NY;
    xrangeup = linspace(xrange(1), xrange(end), NXFine);
    yrangeup = linspace(yrange(1), yrange(end), NYFine);
    dx = xrangeup(2) - xrangeup(1);
    dy = yrangeup(2) - yrangeup(1);
    
    Y = 0.5*(I(:, 2) - I(:, 1));%Triangle tips
    
    L = zeros(length(yrangeup), length(xrangeup));
    
    for ii = 1:size(I, 1)
        x = [I(ii, 1), I(ii, 2), 0.5*sum(I(ii, :))];
        y = [0, 0, Y(ii)];
        x = 1 + round((x - xrangeup(1))/dx);
        y = 1 + round((y - yrangeup(1))/dy);
        L = L + poly2mask(x, y, length(yrangeup), length(xrangeup));
    end
    L = imresize(L, 1.0/UpFac, 'box');
end