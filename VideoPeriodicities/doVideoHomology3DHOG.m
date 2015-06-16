%Borrowing from the algorithm in Klaser, Alexander, and Marcin Marszalek. 
%"A spatio-temporal descriptor based on 3d-gradients." (2008).

%W, H, L: Width (pixels), Height (pixels), Length (frames) of each 3D HOG
%block that's computed (Default 12x12x6)
function [I, J, JGenerators, D, SampleDelays] = doVideoHomology3DHOG( filename, W, H, L )
    if nargin < 2
        W = 12;
    end
    if nargin < 3
        H = 12;
    end
    if nargin < 4
        L = 6;
    end
    addpath('../TDAMex');
    
    obj = VideoReader(filename);
    N = obj.NumberOfFrames;
    SampleDelays = linspace(0, obj.Duration, N);    
    
    hogs = get3DHOGSlow(filename, W, H, L);
    D = squareform(pdist(hogs));
    minDist = min(D(:));
    maxDist = max(D(:));
    
    save('D.mat', 'D');
    
    [I, J, JGenerators] = getGeneratorsFromTDAJar(D, maxDist);
    plotPersistenceDiagrams(I, J, minDist, maxDist);
    [~, genOrder] = sort(J(:, 2));%Sort the points in increasing order of death time
    dimx = 5;
    figure;
    for i = 1:dimx*dimx
       subplot(dimx, dimx, i);
       %plot(SampleDelays(JGenerators{genOrder(i)}));
       plot(JGenerators{genOrder(i)});
       xlabel('Sample Number');
       ylabel('Frame Number');
       title( sprintf('%g', J(genOrder(i), 2) - J(genOrder(i), 1)) );
    end
end
