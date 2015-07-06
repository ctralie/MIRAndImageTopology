ANTIALIAS_FACTOR = 20;
IMWIDTH = 300;
IMHEIGHT = 150;
STRINGWIDTH = 5;

NSamples = 1000;
Amplitude = 1.0;% #1 pixel amplitude
NHarmonics = 20;

x = linspace(-1, 1, NSamples);
NPeriods = 50;
SamplesPerPeriod = 10;
t = linspace(0, 2*pi*NPeriods, NPeriods*SamplesPerPeriod);

y = zeros(1, NSamples);
for h = 1:2:2*NHarmonics+1
    y = y + (1.0/h^2)*((-1).^((h-1)/2)).*sin(h*pi*(x+1)/2);
end
Amplitude = Amplitude/max(y);

for tidx = 1:length(t)
    tidx
    y = zeros(1, NSamples);
    for h = 1:2:2*NHarmonics+1
        y = y + (1.0/h^2)*((-1)^((h-1)/2)).*cos(h*t(tidx)).*sin(h*pi*(x+1)/2);
    end
    y = Amplitude*y;
    plot(x, y, 'LineWidth', STRINGWIDTH);
    xlim([-1, 1]);
    ylim([-1, 1]);
    axis off;
    print('-dpng', sprintf('-r%i', 25*ANTIALIAS_FACTOR), sprintf('%i.png', tidx));
    system(sprintf('convert %i.png -scale %ix%i %i.png', tidx, IMWIDTH, IMHEIGHT, tidx));
end