function [] = viewVideoReordered( V, Y, idx )
    Z = Y(idx, :);
    dotZ = dot(Z, Z, 2);
    D = bsxfun(@plus, dotZ, dotZ') - 2*(Z*Z');
    for ii = 1:size(Y, 1)
        clf;
        subplot(2, 2, 1);
        thisFrame = V{idx(ii)};
        imagesc(thisFrame);
        axis off;
        
        subplot(2, 2, 2);
        imagesc(D);
        hold on;
        plot([0, size(Y, 1)], [ii, ii], 'r');
        axis off;
        
        subplot(2, 2, 3:4);
        hold on;
        scatter(Y(:, 1), Y(:, 2), 20, 'r', 'fill');
        scatter(Y(idx(ii), 1), Y(idx(ii), 2), 100, 'k', 'fill');
        axis off;
        print('-dpng', '-r100', sprintf('%i.png', ii));
    end
end

