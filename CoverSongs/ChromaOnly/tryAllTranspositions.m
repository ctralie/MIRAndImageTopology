function [] = tryAllTranspositions( s1prefix, s2prefix, M )
    X = getBeatSyncChromaDelay(s1prefix, M);
    for ii = 0:35
        [Y, CY] = getBeatSyncChromaDelay(s2prefix, M, ii);
        
        Comp = zeros(size(X, 1), size(Y, 1), size(Y, 2));%Full oti comparison matrix
        %Do OTI on each element individually
        for cc = 0:size(Y, 2)-1
            thisY = getBeatSyncChromaDelay(s2prefix, M, cc, CY);
            Comp(:, :, cc+1) = X*thisY';
        end
        [~, Comp] = max(Comp, [], 3);
        CSM = (Comp == 1) + (Comp == 2) + (Comp == size(Y, 2));
        CSM(CSM > 0) = 1;
        D = double(CSM);

        imagesc(D);
        title(sprintf('Shift %i', ii));
        print('-dpng', '-r100', sprintf('%i.png', ii));
    end
end

