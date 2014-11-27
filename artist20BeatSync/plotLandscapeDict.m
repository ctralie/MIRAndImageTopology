function [] = plotLandscapeDict(idx)
    load('LandscapeDs.mat');

    LandscapeRes = 100;
    xrangeLandscape = linspace(0, 2, LandscapeRes);
    yrangeLandscape = linspace(0, 0.6, LandscapeRes);    
    
    Dict = LandscapeDs{idx};
    
    for ii = 1:6
        for jj = 1:5
            idx = (ii-1)*5 + jj;
            I = reshape(Dict(:, idx), LandscapeRes, LandscapeRes);
            subplot(6, 5, idx);
            imagesc(xrangeLandscape, yrangeLandscape, I);
            set(gca, 'YDir', 'Normal');
        end
    end

end