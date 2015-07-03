Width = 400;
Height = 200;
Sigma = 0.01;
x = linspace(0, 2, Width);
NHarmonics = 100;
y = zeros(1, length(x));
for h = 1:2:NHarmonics*2+1
    y = y + (1/h^2)*((-1)^((h-1)/2))*sin(pi*h*x);
end
y = (0.95/max(y))*y;
HeightFac = 100;

height = linspace(-1, 1, HeightFac*Height);
height = repmat(height(:), [1 length(x)]);
t = linspace(0, 32*pi, 100);
V = zeros(length(t), Height, Width, 3);
disp('Generating Frames');
for ii = 1:length(t)
    ii
    wave = sin(t(ii))*y;
    wave = repmat(wave, [HeightFac*Height, 1]);
    IM = (wave-height).^2;
    IM = exp(-IM/(Sigma^2));
    IM = imresize(IM, [Height, Width]);
    IM = bsxfun(@times, 1./sum(IM, 1), IM);
    for cc = 1:3
        V(ii, :, :, cc) = IM;
    end
end
V = uint8((255/max(V(:)))*V);

disp('Writing Video');
writerObj = VideoWriter('standingwave.avi');
open(writerObj);
for ii = 1:size(V, 1)
    ii
    writeVideo(writerObj, squeeze(V(ii, :, :, :)));
end
close(writerObj);