function [] = plotPersistenceDiagrams( I, J, minDist, maxDist )
    c = [0 0 1; 0 1 0; 1 0 0; 1 1 0; 0 1 1; 1 0 1];

    subplot(1, 2, 1);
    plot(I(:, 1), I(:, 2), '.');
    xlim([minDist, maxDist]);
    ylim([minDist, maxDist]);
    axis square;
    title('0D Persistence Diagram');
    xlabel('Birth Time');
    ylabel('Death Time');
    
    colors = mod((1:size(J, 1)) - 1, size(c, 1)) + 1;
    colors = c(colors, :);
    subplot(1, 2, 2);
    if size(J, 1) > 0
      scatter(J(:, 1), J(:, 2), 20, colors);
    end
    minDist = min(J(:));
    maxDist = max(J(:));
    xlim([minDist, maxDist]);
    ylim([minDist, maxDist]);
    hold on;
    plot([minDist, maxDist], [minDist, maxDist], 'r');
    axis square;
    title('1D Persistence Diagram');
    xlabel('Birth Time');
    ylabel('Death Time');
end