function [Landscapes] = getAllLandscapes(X, res)
    addpath('..');
    N = length(X);
    %Come up with a bounding box for all persistence diagrams
    I = cell2mat(X);
    Bs = I(:, 1);
    Ls = I(:, 2) - I(:, 1);
    xrange = linspace(min(Bs), max(Bs), res);
    yrange = linspace(0, 0.5*max(Ls), res); %Ignore immortal classes
    
    Landscapes = cell(N, 1);
    for ii = 1:N
        ii
        Landscapes{ii} = getRasterizedLandscape(X{ii}, xrange, yrange, 5);
        imagesc(flipud(Landscapes{ii}));
        print('-dpng', sprintf('%i.png', ii));
    end
end