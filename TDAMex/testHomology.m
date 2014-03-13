X = rand(100, 2);
%X = 0:0.05:1;
%X = [cos(2*pi*X') sin(2*pi*X')];
%X = [X; X + 0.2.*rand(21, 2); X + 0.1.*rand(21, 2)];
%X = [-1 0; 0 1; 1 0; 0 -1];
D = squareform(pdist(X));
%D = [0 1 6 4; 1 0.1 2 5; 6 2 0.2 3; 4 5 3 0.3];
%D = [0 1 6 7 5; 1 0.1 2 10 8; 6 2 0.2 3 9; 7 10 3 0.3 4; 5 8 9 4 0.4];
minDist = -1;
maxDist = max(D(:));

maxEdgeLength = 0.2;
[I, J, generators, cycleDists] = getGeneratorsFromTDAJar(D, maxEdgeLength);
plotPersistenceDiagrams(I, J, minDist, maxDist);
[~, genRange] = sort(J(:, 2) - J(:, 1), 'descend');
figure;
genRange = genRange(1:min(16, size(J, 1)));
dimx = floor(sqrt(length(genRange)));
for i = 1:dimx*dimx
    subplot(dimx, dimx, i);
    plotPersistenceGenerators(X, generators, genRange(i));
    title( sprintf('%g', J(genRange(i), 2) - J(genRange(i), 1)) );
end