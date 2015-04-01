function [] = tryAllTranspositions( s1prefix, s2prefix, M )
    X = getBeatSyncChromaDelay(s1prefix, M);
    for ii = 0:35
        Y = getBeatSyncChromaDelay(s2prefix, M, ii);
        D = pdist2(X, Y);
        imagesc(D);
        title(sprintf('Shift %i', ii));
        print('-dpng', '-r100', sprintf('%i.png', ii));
    end
end

