init;
NScales = 100;

%Step 1: Add a bunch of cosines together
SamplesPerPeriod = 20;
NPeriods = 15;
NSamples = NPeriods*SamplesPerPeriod;
mfp = [1 1 0.5; 0.5 1.5 0.3; 0.8 2 0; 1 3 0.1; 0.6 4.5 0];
NSines = size(mfp, 1);

%Figure out the full period length (assuming I only go out to 1 decimal
%place with my frequencies)
Period = 2;
Period = Period*2*pi;

t = linspace(0, Period*NPeriods, NSamples);
tfine = linspace(0, Period, NSamples);
S = linspace(0, 1, NScales);

for sinei = 2:NSines
    for kk = 1:length(S)
        clf;
        y = zeros(NSines, NSamples);
        yfine = zeros(NSines, NSamples);
        for ii = 1:sinei
            if ii == sinei
                y(ii, :) = S(kk)*mfp(ii, 1)*sin(mfp(ii, 2)*t + mfp(ii, 3));
                yfine(ii, :) = S(kk)*mfp(ii, 1)*sin(mfp(ii, 2)*tfine + mfp(ii, 3));
            else
                y(ii, :) = mfp(ii, 1)*sin(mfp(ii, 2)*t + mfp(ii, 3));
                yfine(ii, :) = mfp(ii, 1)*sin(mfp(ii, 2)*tfine + mfp(ii, 3));
            end
        end
        y = sum(y, 1)';
        yfine = sum(yfine, 1)';
        %Step 2: Delay embedding (need 2*number of Fourier component dimensions)
        WindowLen = 2*NSines;
        Y = zeros(length(y) - WindowLen + 1, WindowLen);
        for ii = 1:WindowLen
            Y(:, ii) = y(ii:length(y)-WindowLen+ii);
        end
        I = rca1pc(Y, 1e9);
        subplot(1, 2, 1);
        plot(yfine);
        title(sprintf('%i Sines (%i percent)', sinei, round(100*S(kk))));
        ylim([-sum(mfp(:, 1)), sum(mfp(:, 1))]);
        subplot(1, 2, 2);
        plotpersistencediagram(I);
        xlim([0, 5.5]);
        ylim([0, 5.5]);
        set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 4])
        print('-dpng', '-r100', sprintf('%i.png', kk+(sinei-2)*length(S)));
    end
end
