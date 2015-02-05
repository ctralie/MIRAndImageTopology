if 0
[I, J] = meshgrid(-5:40, -5:40);
D = -exp(- (((I-3).^2 + (J-3).^2)/10) ) -1.1*exp(- (((I+3).^2 + (J+3).^2)/10) );
[I0, IGenerators] = morseFiltration2DMex(D);
imagesc(D);
hold on;
for ii = 1:length(IGenerators)
    g = IGenerators{ii} + 1;
    [birthi, birthj] = ind2sub(size(D), g(end));
    plot(birthi, birthj, 'rx');
    [birthi, birthj] = ind2sub(size(D), g(1:end-1));
    plot([birthi birthi(1)], [birthj birthj(1)], 'b');
    scatter(birthi, birthj, 10, 'b', 'fill');
end

end

if 1
load('TestDists.mat');
D2 = fliplr(flipud(D2));

tic
[I11, Generators11] = morseFiltration2DMex(D1);
[I12, Generators12] = morseFiltration2DMex(max(D1(:))-D1);
[I21, Generators21] = morseFiltration2DMex(D2);
[I22, Generators22] = morseFiltration2DMex(max(D2(:))-D2);
toc

subplot(1, 2, 1);
imagesc(D1);
hold on;
for kk = 1:length(Generators11)
   g = Generators11{kk} + 1;
   [birthi, birthj] = ind2sub(size(D1), g(end));
   plot(birthi, birthj, 'kx');
   [geni, genj] = ind2sub(size(D1), g(1:end-1));
   plot([geni geni(1)], [genj genj(1)], 'k');
end
for kk = 1:length(Generators12)
   g = Generators12{kk} + 1;
   [birthi, birthj] = ind2sub(size(D1), g(end));
   plot(birthi, birthj, 'cx');
   [geni, genj] = ind2sub(size(D1), g(1:end-1));
   plot([geni geni(1)], [genj genj(1)], 'c');
end
axis equal;
colormap('jet');
title('Self-Similarity Matrix Original Beat');

subplot(1, 2, 2);
imagesc(D2);
hold on;
for kk = 1:length(Generators21)
   g = Generators21{kk} + 1;
   [birthi, birthj] = ind2sub(size(D2), g(end));
   plot(birthi, birthj, 'kx');
   [geni, genj] = ind2sub(size(D2), g(1:end-1));
   plot([geni geni(1)], [genj genj(1)], 'k');
end
for kk = 1:length(Generators22)
   g = Generators22{kk} + 1;
   [birthi, birthj] = ind2sub(size(D2), g(end));
   plot(birthi, birthj, 'cx');
   [geni, genj] = ind2sub(size(D2), g(1:end-1));
   plot([geni geni(1)], [genj genj(1)], 'c');
end
axis equal;
colormap('jet');
title('Self-Similarity Matrix Cover Beat');
end