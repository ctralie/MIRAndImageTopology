init;
Delta = 5;%1/10th of a beat
files = {'AnyWayYouWantIt', 'AnyWayYouWantIt_Cover2', 'Rude', 'Rude_Cover1'};
DGMS = cell(1, length(files));

for ii = 1:length(files)
    file = files{ii};
    load([file, '.mat']);
    [Curv, ContigDists, SkipDists] = getSongApproxCurvature(MFCC, Delta);
    DGMS{ii} = morseFiltration(Curv-1);
end

hold on;
colors = {'r', 'g', 'b', 'c'};
hists = cell(1, length(DGMS));
bins = linspace(0, 0.2, 50);
for ii = 1:length(DGMS)
    I = DGMS{ii};
    hists{ii} = hist(I(:, 2) - I(:, 1), bins);
    hists{ii} = hists{ii}/sqrt(sum(hists{ii}.^2));
    bar(bins, hists{ii}, 1.0/2.0^(ii-1), 'FaceColor', colors{ii}, 'EdgeColor', colors{ii});
end
legend(files);
title('Persistence of Morse Filtrations over Curvature');