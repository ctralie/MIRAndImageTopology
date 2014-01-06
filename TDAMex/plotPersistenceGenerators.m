function [] = plotPersistenceGenerators( X, generators, genRange )
    c = [0 0 1; 0 1 0; 1 0 0; 1 1 0; 0 1 1; 1 0 1];
    %Now plot the generators
    plot(X(:, 1), X(:, 2), '.');
    hold on;

    for i = genRange
       V = X(generators{i}, :);
       V = V+0.001*rand(size(V));
       cmapIndex = mod((i-1), size(c, 1))+1;
       plot(V(:, 1), V(:, 2), 'o', 'Color', c(cmapIndex, :), 'LineWidth', 2);
    end

    for i = genRange
       V = X(generators{i}, :);
       V = V+0.001*rand(size(V));
       cmapIndex = mod((i-1), size(c, 1))+1;
       V = [V; V(1, :)];
       for k = 1:length(V)-1
          plot([V(k, 1) V(k+1, 1)], [V(k, 2), V(k+1, 2)], 'Color', c(cmapIndex, :), 'LineWidth', 2);
       end
    end

end