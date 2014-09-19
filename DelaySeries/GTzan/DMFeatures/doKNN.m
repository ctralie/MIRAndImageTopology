replicateDMPCs;

AllPCIndices = {};
myresults = [];
DMresults = [];

for setsize = 1:5
    PCIndices = combntns(1:5, setsize);
    for aa = 1:size(PCIndices, 1)
        PCIdx = PCIndices(aa, :);
        X = zeros(length(files), 3*setsize);
        MyX = zeros(length(files), 3*setsize);
        genres = zeros(length(files), 1);

        for ii = 1:length(songs)
            song = songs{ii};
            X(ii, :) = [song.principalComp200I1Timbre(:, PCIdx) song.principalComp200I1MFCC(:, PCIdx) song.principalComp200I1Chroma(:, PCIdx)];
            MyX(ii, :) = [song.principalComp200I1Timbre_Chris(:, PCIdx) song.principalComp200I1MFCC_Chris(:, PCIdx) song.principalComp200I1Chroma_Chris(:, PCIdx)];
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
        string = 0;
        for ii = 1:length(PCIdx)
            string = string + 10^(length(PCIdx) - ii)*PCIdx(ii);
        end
        AllPCIndices{end+1} = mat2str(string);
        DMresults = [DMresults sum(diag(C))/sum(C(:))];
        myresults = [myresults sum(diag(MyC))/sum(MyC(:))];
    end
end

plot(myresults);
hold on;
plot(DMresults, 'r');
legend({'My Results', 'Derrick/Marshall Results'});
scatter(1:length(myresults), myresults);
scatter(1:length(DMresults), DMresults);
set(gca, 'XTick', 1:length(DMresults));
set(gca, 'XTickLabel', AllPCIndices);
title('Genere Classification Accuracy Based on Subsets of Principal Components');
xlabel('Principal Components Taken');
ylabel('Accuracy');