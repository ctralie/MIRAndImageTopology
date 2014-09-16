replicateDMPCs;

X = zeros(length(files), 15);
MyX = zeros(length(files), 15);
genres = zeros(length(files), 1);

for ii = 1:length(songs)
    song = songs{ii};
    X(ii, :) = [song.principalComp200I1Timbre song.principalComp200I1MFCC song.principalComp200I1Chroma];
    MyX(ii, :) = [song.principalComp200I1Timbre_Chris song.principalComp200I1MFCC_Chris song.principalComp200I1Chroma_Chris];
    genres(ii) = song.genre;
end

k = 5;%How many neighbors
permidx = randperm(length(songs));
X = X(permidx, :);
MyX = MyX(permidx, :);
genres = genres(permidx);
D = squareform(pdist(X));
MyD = squareform(pdist(MyX));
[~, NeighbIDX] = sort(D, 2);
[~, MyNeighbIDX] = sort(MyD, 2);
NeighbIDX = genres(NeighbIDX(:, 1:k));
NeighbIDX = mode(NeighbIDX, 2);
MyNeighbIDX = genres(MyNeighbIDX(:, 1:k));
MyNeighbIDX = mode(MyNeighbIDX, 2);
C = zeros(10, 10); %Confusion Matrix
MyC = zeros(10, 10);
for ii = 1:length(NeighbIDX)
    C(genres(ii), NeighbIDX(ii)) = C(genres(ii), NeighbIDX(ii)) + 1;
    MyC(genres(ii), MyNeighbIDX(ii)) = MyC(genres(ii), MyNeighbIDX(ii)) + 1;
end
sum(diag(C))/sum(C(:))
sum(diag(MyC))/sum(MyC(:))