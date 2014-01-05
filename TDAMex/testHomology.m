X = rand(50, 2);
%X = 0:0.05:1;
%X = [cos(2*pi*X') sin(2*pi*X')];
%X = [-1 0; 0 1; 1 0; 0 -1];
D = squareform(pdist(X));
%D = [0 1 6 4; 1 0.1 2 5; 6 2 0.2 3; 4 5 3 0.3];
%D = [0 1 6 7 5; 1 0.1 2 10 8; 6 2 0.2 3 9; 7 10 3 0.3 4; 5 8 9 4 0.4];
minDist = -1;
maxDist = max(D(:));

% hold on;
% for i = 1:size(X, 1)
%  for j = i+1:size(X, 1)
%     plot(X([i, j], 1), X([i, j], 2), 'r');
%  end
% end

javaclasspath('jars/tda.jar');
import api.*;
tda = Tda();
tda.RCA1( { 'settingsFile=data/cts.txt', 'supplyDataAs=distanceMatrix'}, D );
disp('Finished Persistent Homology');
I1 = tda.getResultsRCA1(0).getIntervals();
J1 = tda.getResultsRCA1(1).getIntervals();

subplot(2, 2, 1);
plot(I1(:, 1), I1(:, 2), '.');
xlim([minDist, maxDist]);
ylim([minDist, maxDist]);
axis square;
title('0D Persistence Diagram');

subplot(2, 2, 2);
if size(J1, 1) > 0
  plot(J1(:, 1), J1(:, 2), '.');
end
xlim([minDist, maxDist]);
ylim([minDist, maxDist]);
hold on;
plot([0, maxDist], [0, maxDist], 'r');
axis square;
title('1D Persistence Diagram');

tic;
[I2, J2, generators] = Persistence0D1D(D);
toc;
subplot(2, 2, 3);
plot(I2(:, 1), I2(:, 2), '.');
xlim([minDist, maxDist]);
ylim([minDist, maxDist]);
axis square;
title('0D Persistence Diagram');

c = [0 0 1; 0 1 0; 1 0 0; 1 1 0; 0 1 1; 1 0 1];
colors = mod((1:size(J2, 1)) - 1, size(c, 1)) + 1;
colors = c(colors, :);
size(colors)
size(J2)
subplot(2, 2, 4);
if size(J2, 1) > 0
  scatter(J2(:, 1), J2(:, 2), 20, colors);
end
xlim([minDist, maxDist]);
ylim([minDist, maxDist]);
hold on;
plot([0, maxDist], [0, maxDist], 'r');
axis square;
title('1D Persistence Diagram');


%Now plot the generators
figure;
plot(X(:, 1), X(:, 2), '.');
hold on;


% for i = 1:length(generators)
%    V1 = X(generators{i}(:, 1), :);
%    V2 = X(generators{i}(:, 2), :);
%    cmapIndex = mod((i-1), size(c, 1))+1;
%    V1 = V1 + 0.001*rand(size(V1));
%    V2 = V2 + 0.001*rand(size(V2));
%    for k = 1:length(V1)
%       plot([V1(k, 1) V2(k, 1)], [V1(k, 2), V2(k, 2)], 'Color', c(cmapIndex, :), 'LineWidth', 2);
%    end
% end


for i = 1:length(generators)
   V = X(generators{i}, :);
   V = V+0.001*rand(size(V));
   cmapIndex = mod((i-1), size(c, 1))+1;
   plot(V(:, 1), V(:, 2), 'o', 'Color', c(cmapIndex, :), 'LineWidth', 2);
   %V = [V; V(1, :)];
   %for k = 1:length(V)-1
   %    plot([V(k, 1) V(k+1, 1)], [V(k, 2), V(k+1, 2)], 'r');
   %end
end

for i = 1:length(generators)
   V = X(generators{i}, :);
   V = V+0.001*rand(size(V));
   cmapIndex = mod((i-1), size(c, 1))+1;
   V = [V; V(1, :)];
   for k = 1:length(V)-1
      plot([V(k, 1) V(k+1, 1)], [V(k, 2), V(k+1, 2)], 'Color', c(cmapIndex, :), 'LineWidth', 2);
   end
end
