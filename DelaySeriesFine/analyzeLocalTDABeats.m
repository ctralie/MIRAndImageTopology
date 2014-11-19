load('1.mat');
MaxTime = SampleDelays{end}(end)/Fs;
bts = bts(bts > 0 & bts <= MaxTime);
AllIs = [];
AllGenerators = {};

for ii = 1:length(Is)
    for kk = 1:size(Is{ii}, 1)
        AllGenerators{end+1} = SampleDelays{ii}(Generators{ii}{kk})/Fs;
        AllIs = [AllIs; Is{ii}(kk, :)];
    end
end

[~, idx] = sort(AllIs(:, 2) - AllIs(:, 1));
% N = 16;
% k = sqrt(N);
% for ii = 1:N
%     subplot(k, k, ii);
%     gen = AllGenerators{idx(ii)};
%     plot(gen);
%     title(sprintf('%g (%g)', max(gen) - min(gen), AllIs(idx, 2) - AllIs(idx, 1)));
% end

% AllTimes = zeros(length(AllGenerators), 1);
% for ii = 1:length(AllGenerators)
%     AllTimes(ii) = max(AllGenerators{ii}) - min(AllGenerators{ii});
% end

AllTimes = zeros(length(Generators), 1);
for ii = 1:length(Generators)
    if size(Is{ii}, 1) > 0
        [~, idx] = max(Is{ii}(:, 2) - Is{ii}(:, 1));
        gen = SampleDelays{ii}(Generators{ii}{idx})/Fs;
        AllTimes(ii) = max(gen) - min(gen);
    end
end

meanbts = mean(bts(2:end) - bts(1:end-1));
meantda = mean(AllTimes);

[btshist, btsbars] =  hist(bts(2:end) - bts(1:end-1));
[tdahist, tdabars] = hist(AllTimes, 20);
btsbars = [btsbars btsbars*2 btsbars*3];
btshist = [btshist btshist btshist];



bar(tdabars, tdahist, 'r');
hold on;
bar(btsbars, btshist, 'b');
legend({'TDA', 'GroundTruth'});

plot(meantda, 15, 'r*');
plot([meanbts meanbts*2 meanbts*3], [15, 15, 15], 'b*');