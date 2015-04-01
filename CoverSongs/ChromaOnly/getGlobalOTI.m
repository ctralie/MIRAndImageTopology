function [ oti, corrs ] = getGlobalOTI( s1prefix, s2prefix )
%Get the "optimal transposition index" to put chroma 1 into 
%chroma 2's key.
    song1 = load(['../covers80/TempoEmbeddings/', s1prefix, '.mat']);
    song2 = load(['../covers80/TempoEmbeddings/', s2prefix, '.mat']);
    Chroma1 = song1.Chroma;
    Chroma2 = song2.Chroma;
    %Take the means before taking the maxes
    Chroma1 = mean(Chroma1, 1);
    MaxChroma1 = max(Chroma1, [], 2);
    MaxChroma1(MaxChroma1 == 0) = 1; %Prevent divide by zeros
    Chroma1 = bsxfun(@times, 1./MaxChroma1, Chroma1);

    Chroma2 = mean(Chroma2, 1);
    MaxChroma2 = max(Chroma2, [], 2);
    MaxChroma2(MaxChroma2 == 0) = 1; %Prevent divide by zeros
    Chroma2 = bsxfun(@times, 1./MaxChroma2, Chroma2);
    
    corrs = zeros(1, size(Chroma1, 2));
    
    for ii = 0:size(Chroma1, 2) - 1
        corr = circshift(Chroma1, ii, 2).*Chroma2;
        corr = sum(corr(:));
        corrs(ii+1) = corr;
    end
    [~, oti] = max(corrs);
    oti = oti - 1; %Matlab zero-indexing
end