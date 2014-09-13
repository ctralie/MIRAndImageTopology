%Programmer: Chris Tralie
%Purpose: To aggregate all of the computed features after running
%"computeGTzanFeatures" on all genres
featuresOrig = {};
AllPDs0 = {};
AllPDs1 = {};
indices = 1:10;
for ii = 1:length(indices)
    a = load(sprintf('GTzanFeatures%i.mat', indices(ii)));
    featuresOrig{end+1} = a.X;
    AllPDs0{end+1} = a.PDs0;
    AllPDs1{end+1} = a.PDs1;
end
genres = a.genres(indices);
save('GTzanFeatures.mat', 'genres', 'featuresOrig', 'AllPDs0', 'AllPDs1');