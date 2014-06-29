addpath('../TDAMex');
load('DMatrices/DBeatingHeart_HOG3D.mat');
N = size(D, 1);
M = 40;
offsets = 1:N-M-1;
persistences = zeros(1, length(offsets));
maxGenerators = cell(1, length(offsets));
J = zeros(length(offsets), 2);
for ii = offsets
    fprintf(1, '%i of %i\n', ii, length(offsets));
    DSub = D(ii:ii+40-1, ii:ii+40-1);
    minDist = min(DSub(:));
    maxDist = max(DSub(:));
    [I, thisJ, JGenerators] = getGeneratorsFromTDAJar(DSub, maxDist);
    if ~isempty(thisJ)
        [persistences(ii), idx] = max(thisJ(:, 2) - thisJ(:, 1));
        maxGenerators{ii} = JGenerators{idx} + (ii-1);
        J(ii, :) = thisJ(idx, :);
    end
end

save('BeatingHeartParts.mat', 'J', 'maxGenerators');

plot(offsets, persistences);
%Get rid of duplicate persistence pairs
unique = ones(size(persistences));
lastGenerator = maxGenerators{1};
for ii = 2:length(unique)
    if length(lastGenerator) ~= length(maxGenerators{ii})
       unique(ii) = 0;
    elseif sum(sort(lastGenerator) == sort(maxGenerators{ii})) == length(lastGenerator)
       unique(ii) = 0;
    end
    lastGenerator = maxGenerators{ii};
end
fprintf(1, 'There are %i unique generators\n', sum(unique));
J = J(unique == 1, :);
maxGenerators = maxGenerators(unique == 1);


saveVideoGenerators( 'BeatingHeart.mp4', 'BeatingHeartPartial', J, maxGenerators, sum(unique), D);