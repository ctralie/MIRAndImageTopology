%Step 1: Add a bunch of cosines together
if ~exist('AUTOMATED')
    mfp = [1 1 0.5; 0.5 1.5 0.3];%; 0.8 2 0; 0.3 2 0.1];%; 0.6 1.3 0];
    windowLen = 5;
    SamplesPerPeriod = 30;
    NPeriods = 50;
end
%Figure out the full period length (assuming I only go out to 1 decimal
%place with my frequencies)
Period = 10*mfp(1, 2);
for ii = 2:size(mfp, 1)
    Period = lcm(Period, 10*mfp(ii, 2));
end
if mod(Period, 10) == 0
    Period = Period/10;
end
fprintf(1, 'Period is 2*pi*%i\n', Period);
Period = 2*pi*Period;

NSamples = NPeriods*SamplesPerPeriod;
t = linspace(0, Period*NPeriods, NSamples);
tfine = linspace(0, Period, NSamples);
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

%Step 3: Build Derivative Matrix amd apply to 1D signal
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
Y = Y((NTap-1)/2+1:end, :);
%Take care of some tricky boundary stuff
if size(Y, 1) > length(yp)
    Y = Y(1:length(yp), :);
else
    yp = yp(1:size(Y, 1), :);
    A = A(1:size(Y, 1), :);
    AInv = pinv(full(A));
end
path = doTSP(squareform(pdist(Y)), 0);

%Step 5: Reconstruct after reordering using original derivatives
clf;
subplot(2, 2, 1:2);
yr = AInv*yp(path);
plot(y, 'b');
hold on;
plot(yr, 'r');
legend({'Original', 'Reconstructed'});
title(sprintf('%i Sines %i Periods %i Samples %i Taps', NSines, NPeriods, SamplesPerPeriod, NTap));

%Plot original fine signal against a rescaled version of the reconstructed
%signal to see if the shape changes at all
subplot(2, 2, 3);
plot(yfine);
title('Original Finely Sampled');

subplot(2, 2, 4);
plot(yp(path));
title('Reordered Derivative');