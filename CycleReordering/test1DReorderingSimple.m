%Add a bunch of cosines together
SamplesPerPeriod = 10;
NPeriods = 20;
t = linspace(0, 2*pi*NPeriods, SamplesPerPeriod*NPeriods);
t = t(:);
y = cos(t(:));
%Delay embedding
Y = [y(1:end-1), y(2:end)];

%Make plots
subplot(2, 2, 1);
plot(y);
title('Original');
subplot(2, 2, 2);
plot(Y(:, 1), Y(:, 2), '.');
title('Delay Embedding');
Y = bsxfun(@minus, mean(Y, 1), Y);
Y = bsxfun(@times, 1./sqrt(sum(Y.^2, 2)), Y);
subplot(2, 2, 4);
plot(Y(:, 1), Y(:, 2), '.');
title('Normalized Delay Embedding');
%Circular coordinates
theta = atan2(Y(:, 2), Y(:, 1));
[~, idx] = sort(theta);
subplot(2, 2, 3);
plot(y(idx));
title('Resorted by Delay Coordinate Angles');