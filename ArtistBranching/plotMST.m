function [] = plotMST( D, X )
    N = size(D, 1);
    plot(X(:, 1), X(:, 2), '.');
    hold on;
    for i = 1:N
       for j = i+1:N
           if D(i, j) == 1
              xs = [X(i, 1), X(j, 1)];
              ys = [X(i, 2), X(j, 2)];
              plot(xs, ys, 'r');
           end
       end
    end
end