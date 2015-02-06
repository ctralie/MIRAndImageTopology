init;
t = linspace(0, 2*pi, 100);
X = [cos(t(:)) sin(t(:))];
X = [X; 2+0.5*cos(t(:)) 2+0.5*sin(t(:))];
Y = X+0.03*randn(size(X));
I1 = rca1pc(X, 1e9);
I2 = rca1pc(Y, 1e9);
idx = randperm(size(I2, 1));
I2 = I2(idx, :);

[matchidx, matchdist, D] = getWassersteinDist(I1, I2);

clf;
subplot(1, 2, 1);
plot(X(:, 1), X(:, 2), 'b.');
hold on;
plot(Y(:, 1), Y(:, 2), 'r.');

subplot(1, 2, 2);
hold on;
plot(I1(:, 1), I1(:, 2), 'b.');
plot(I2(:, 1), I2(:, 2), 'bx');
r = [min(I1(:)) max(I1(:))];
plot(r, r, 'r');
for ii = 1:size(matchidx, 1)
    jj = find(matchidx(ii, :), 1);
    if (ii > size(I1, 1))
        if (jj <= size(I2, 1))
            x = [I2(jj, :); I2(jj, 1) I2(jj, 1)];
            plot(x(:, 1), x(:, 2), 'g');
        end
    else
        if (jj <= size(I2, 1))
            x = [I1(ii, :); I2(jj, :)];
            plot(x(:, 1), x(:, 2), 'g');
        else
            x = [I1(ii, :); I1(ii, 1) I1(ii, 1)];
            plot(x(:, 1), x(:, 2), 'g');
        end
    end
end
title(sprintf('Wasserstein Dist: %g', matchdist));