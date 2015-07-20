ANTIALIAS_FACTOR = 20;
IMWIDTH = 200;
IMHEIGHT = 150;
STRINGWIDTH = 5;

NSamples = 1000;
Amplitude = 0.1;%1.0/(IMHEIGHT);% #1 pixel amplitude
NHarmonics = 0;

x = linspace(-1, 1, NSamples);
NPeriods = 50;
SamplesPerPeriod = 10;
t = linspace(0, 2*pi*NPeriods, NPeriods*SamplesPerPeriod);

y = zeros(1, NSamples);
for h = 1:NHarmonics+1
    y = y + sin(h*pi*(x+1)/2);
end
Amplitude = Amplitude/max(y);

for tidx = 1:length(t)
    y = zeros(1, NSamples);
    for h = 1:NHarmonics+1
        y = y + cos(h*t(tidx)).*sin(h*pi*(x+1)/2);
    end
    y = Amplitude*y;
    plot(x, y, 'Color', [0.1, 0.1, 0.1], 'LineWidth', STRINGWIDTH);
    xlim([-1, 1]);
    ylim([-1, 1]);
    axis off;
    tic;
    print('-dpng', sprintf('-r%i', 25*ANTIALIAS_FACTOR), sprintf('%i.png', tidx));
    toc;
    command = sprintf('convert %i.png -scale %ix%i %i.png', tidx, IMWIDTH, IMHEIGHT, tidx);
    disp(command);
    system(command);
end