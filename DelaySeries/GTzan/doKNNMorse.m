dgms = load('GTzanMorseDiagrams');
dgms = dgms.morseDiagrams;
%nbars = size(dgms{1}{1}, 1);
% for ii = 1:10
%    for jj =  1:100
%        if size(dgms{ii}{jj}, 1) < nbars
%           nbars = size(dgms{ii}{jj}, 1); 
%        end
%    end
% end
nbars = 4000;

Features = zeros(3, 1000, nbars);
genres = zeros(1000, 1);
for ii = 1:10
   for jj =  1:100
        idx = 100*(ii-1) + jj;
        genres(idx) = ii;
        for kk = 1:3
            I = dgms{ii}{jj}{kk};
            featSorted = sort(I(:, 2) - I(:, 1), 'descend');
            if length(featSorted) < nbars
                featSorted = [featSorted; zeros(nbars - length(featSorted), 1)];
            else
                featSorted = featSorted(1:nbars);
            end
            Features(kk, idx, :) = featSorted;
        end
   end
end

[~, PCFeatures1] = pca(squeeze(Features(1, :, :)));%Timbral
[~, PCFeatures2] = pca(squeeze(Features(2, :, :)));%MFCC
[~, PCFeatures3] = pca(squeeze(Features(3, :, :)));%Chroma
addpath('DMFeatures');
PCFeatures1 = MuStdCenter(PCFeatures1);
PCFeatures2 = MuStdCenter(PCFeatures2);
PCFeatures3 = MuStdCenter(PCFeatures3);


NPrC = 5; %How many principal components
k = 5;%How many neighbors
permidx = randperm(1000);
X = [PCFeatures1(permidx, 1:NPrC) PCFeatures2(permidx, 1:NPrC) PCFeatures3(permidx, 1:NPrC)];
genres = genres(permidx);
D = squareform(pdist(X));

[~, NeighbIDX] = sort(D, 2);
NeighbIDX = genres(NeighbIDX(:, 1:k));
NeighbIDX = mode(NeighbIDX, 2);
C = zeros(10, 10); %Confusion Matrix
for ii = 1:length(NeighbIDX)
    C(genres(ii), NeighbIDX(ii)) = C(genres(ii), NeighbIDX(ii)) + 1;
end
sum(diag(C))/sum(C(:))