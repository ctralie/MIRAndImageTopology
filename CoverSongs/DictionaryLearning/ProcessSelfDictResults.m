% AllAlphas = cell(80, 80, 3);
% AllDAlphaAlign = zeros(80, 80, 3);
% AllDFit = zeros(80, 80, 3);
% for ii = 1:80
%     load(sprintf('SelfDicts200/Results%i.mat', ii));
%     AllAlphas(ii, :, :) = alphas;
%     AllDAlphaAlign(ii, :, :) = DAlphaAlign;
%     AllDFit(ii, :, :) = DFit;
% end

% results = zeros(3, 2);
% for ii = 1:3
%     D = squeeze(AllDAlphaAlign(:, :, ii));
%     [~, idx] = max(D, [], 2);
%     results(ii, 1) = sum(idx' == 1:80);
%     D = squeeze(AllDFit(:, :, ii));
%     [~, idx] = min(D, [], 2);
%     results(ii, 2) = sum(idx' == 1:80);
% end

%9, 44, 54, 76

load('SelfDicts200/Results76');
lambdas = [0.1, 1, 10, 100];

DFit = reshape(DFit, 80, 1, length(lambdas));
DFitM = cell2mat(DFit);
alphasS = cellfun(@(x) {full(sum(abs(x), 1))}, alphas);
alphasS = reshape(alphasS, 80, 1, length(lambdas));
alphasS = cell2mat(alphasS);
for lambdaIdx = 1:length(lambdas)
    alphasS(:, :, lambdaIdx) = lambdas(lambdaIdx)*alphasS(:, :, lambdaIdx);
end
Cost = DFitM + alphasS;