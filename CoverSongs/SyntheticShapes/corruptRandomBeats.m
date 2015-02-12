%Add little kinks within beats in the song
function [ Y, BeatIdx ] = corruptRandomBeats( X, SamplesPerWin, NCorruptions, Magnitude )
    NBeats = floor(2*size(X, 1)/SamplesPerWin);
    BeatIdx = randperm(NBeats);
    BeatIdx = BeatIdx(1:NCorruptions);
    Y = X;
    dim = size(X, 2);
    NSamples = size(X, 1);
    t = 1:NSamples;
    t = t(:);
    for ii = 1:length(BeatIdx)
        starti = (BeatIdx(ii)-1)*SamplesPerWin/2;
        %Add a Gaussian bump of a random width and random center
        %to every dimension
        Mu = starti + randi(SamplesPerWin/2);
        Sigma = (SamplesPerWin/4)*rand(1);
        Dir = randn(1, dim);%Choose a random direction for the Gaussian
        Dir = repmat(Dir, [NSamples, 1]);
        gaussWeight = Magnitude*repmat(exp(-(t-Mu).^2/(Sigma.^2)), [1 dim]);
        Y = Y + gaussWeight.*Dir;
    end
end