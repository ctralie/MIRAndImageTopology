X1 = load('DMFeatures/song1.mat');
X1 = [X1.songsDiagram.Timbral X1.songsDiagram.MFCC X1.songsDiagram.Chroma];

X2 = load('DMFeatures/song200.mat');
X2 = [X2.songsDiagram.Timbral X2.songsDiagram.MFCC X2.songsDiagram.Chroma];

I11 = getMorseFiltered0DDiagrams(X1);
I12 = getMorseFiltered0DDiagrams(X1);
I21 = getMorseFiltered0DDiagrams(X2);
I22 = getMorseFiltered0DDiagrams(X2);

plot(I11(:, 1), I11(:, 2), '.');
hold on;
plot(I12(:, 1), I12(:, 2), 'r.');
plot(I21(:, 1), I21(:, 2), 'g.');
plot(I22(:, 1), I22(:, 2), 'k.');

I1Curve = sort([I11(:, 2); I12(:, 2)], 'descend');
I2Curve = sort([I21(:, 2); I22(:, 2)], 'descend');
I1Curve = decimate(I1Curve, 500);
I2Curve = decimate(I2Curve, 500);
figure;
plot(I1Curve);
hold on;
plot(I2Curve, 'g');
% plot(sort(I11(:, 2), 'descend'));
% hold on;
% plot(sort(I12(:, 2), 'descend'), 'r');
% plot(sort(I21(:, 2), 'descend'), 'g');
% plot(sort(I22(:, 2), 'descend'), 'k');