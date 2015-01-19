%Inputs:
%Is: A cell array of beat-synchronous persistence diagrams
%C: A k x N array of k dictionary elements
% xrangeLandscape = linspace(0, 2, 50);
% yrangeLandscape = linspace(0, 0.6, 50);

%Ouptputs:
%str: An array with indices of the closest center in C for each
%persistence diagram in Is
%CReps: Indices of the closest elements in Is to the codebook elements in C
function [str, CReps] = getBeatShapeString( Is, C, xrangeLandscape, yrangeLandscape )
    addpath('../../');
    N = length(xrangeLandscape)*length(yrangeLandscape);
    k = size(C, 1);
    X = zeros(length(Is), N);
    for ii = 1:length(Is)
        L = getRasterizedLandscape(Is{ii}, xrangeLandscape, yrangeLandscape);
        X(ii, :) = L(:);
    end
    str = zeros(k, length(Is));
    for kk = 1:k
        D = repmat(C(kk, :), [length(Is), 1]);
        dX = X - D;
        str(kk, :) = sqrt(sum(dX.*dX, 2))';
    end
    [~, CReps] = min(str, [], 2);
    [~, str] = min(str, [], 1);
end