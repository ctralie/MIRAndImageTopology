%Step 1: Add a bunch of cosines together
if ~exist('AUTOMATED')
    mfp = [1 1 0.5];%; 0.5 1.5 0.3; 0.8 2 0; 0.3 2 0.1];%; 0.6 1.3 0];
    windowLen = 5;
    SamplesPerPeriod = 10;
    NPeriods = 50;
end
NSamples = NPeriods*SamplesPerPeriod;
t = linspace(0, 4*pi*NPeriods, NSamples);
tfine = linspace(0, 20*pi, NSamples);
NSines = size(mfp, 1);

y = zeros(NSines, NSamples);
yfine = zeros(NSines, NSamples);
for ii = 1:NSines
    y(ii, :) = mfp(ii, 1)*sin(mfp(ii, 2)*t + mfp(ii, 3));
    yfine(ii, :) = mfp(ii, 1)*sin(mfp(ii, 2)*tfine + mfp(ii, 3));
end
y = sum(y, 1)';
yfine = sum(yfine, 1)';

%Step 2: Delay embedding (need 2*number of Fourier component dimensions)
Y = zeros(length(y) - 2*NSines + 1, 2*NSines);
for ii = 1:2*NSines
    Y(:, ii) = y(ii:length(y)-NSines*2+ii);
end

%Step 3: Build Derivative Matrix
[A, NTap] = getTimeDerivativeBlockMatrix1D(length(y), windowLen);
AInv = pinv(full(A));
yp = A*y;

% figure(1);
% yr = AInv*yp;
% subplot(2, 2, 1);
% plot(y);
% title('Original Signal');
% subplot(2, 2, 2);
% plot(yp);
% title(sprintf('Derivative (%i Tap)', NTap));
% [U, S, V] = svds(A);
% subplot(2, 2, 3);
% plot(yr);
% title('Reconstructed');
% subplot(2, 2, 4);
% plot(y, yr, '.');
% title('Correlation');

%Step 4: Extract Reordering
Y = Y((NTap-1)/2+1:end-(NTap-1)/2-1+NSines*2, :);
path = doTSP(squareform(pdist(Y)), 0);

%Step 5: Reconstruct after reordering using original derivatives
clf;
subplot(1, 3, 1:2);
yr = AInv*yp(path);
plot(y, 'b');
hold on;
plot(yr, 'r');
legend({'Original', 'Reconstructed'});
title(sprintf('%i Sines %i Periods %i Samples %i Taps', NSines, NPeriods, SamplesPerPeriod, NTap));
subplot(1, 3, 3);
plot(yp(path));
title('Reordered Derivative');