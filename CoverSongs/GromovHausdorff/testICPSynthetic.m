%Y is an ordinary figure 8 with even sampling
t = linspace(0, 1, 400);
Y = [cos(2*pi*t(:)) sin(2*pi*2*t(:))];

%X is a deformed figure 8 with uneven sampling
s = RandStream('mcg16807', 'Seed', 20);
t = s.rand(1, 400);
t = sort(t);
t = t - min(t);
t = t/max(t);
t = t.^1.5;
X = [cos(2*pi*t(:)) sin(2*pi*2*t(:))];
[R, ~, ~] = svd(s.randn(2, 2));
X = X*R;
X = bsxfun(@minus, [-2 3], X);
t = t - 0.3;
t = t(:);
Sigma = 0.01;
X(:, 1) = X(:, 1) + 0.2*exp(-t.*t/(2*Sigma^2));
X(:, 2) = X(:, 2) - 0.1*exp(-t.*t/(2*Sigma^2));
t = t - 0.2;
X(:, 1) = X(:, 1) + 0.5*exp(-t.*t/(2*Sigma^2));
X(:, 2) = X(:, 2) - 0.3*exp(-t.*t/(2*Sigma^2));

plot(X(:, 1), X(:, 2), '.');

[T, P, iters, fs] = FICP(X, Y, 2, 100, 1);