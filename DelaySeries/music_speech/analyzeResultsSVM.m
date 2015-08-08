Music = load('MusicFeatures.mat');
Speech = load('SpeechFeatures.mat');
randSeed = 100;
s = RandStream('mcg16807', 'Seed', randSeed);

NExamples = length(Music.PDs1);
startbar = 1;
endbar = 50;
NBars = endbar - startbar + 1;
NFFT = 20;

XMusicTDA = zeros(NExamples, NBars);
XSpeechTDA = zeros(NExamples, NBars);

for ii = 1:NExamples
    XMusicTDA(ii, :) = getSortedBars(Music.PDs1{ii}{2}, startbar, endbar, 0);
    XSpeechTDA(ii, :) = getSortedBars(Speech.PDs1{ii}{2}, startbar, endbar, 0);
end

FTMusic = abs(fft(XMusicTDA, [], 2));
FTSpeech = abs(fft(XSpeechTDA, [], 2));
FTMusic = FTMusic(:, 1:NFFT);
FTSpeech = FTSpeech(:, 1:NFFT);


% XMusic = Music.X;
% XSpeech = Speech.X;

% XMusic = XMusicTDA;
% XSpeech = XSpeechTDA;

XMusic = [Music.X XMusicTDA];
XSpeech = [Speech.X XSpeechTDA];

XMusic = XMusic(s.randperm(NExamples), :);
XSpeech = XSpeech(s.randperm(NExamples), :);
Mu = mean([XMusic; XSpeech]);
Stdev = std([XMusic; XSpeech]);
XMusic = bsxfun(@minus, Mu, XMusic);
XMusic = bsxfun(@times, 1./Stdev, XMusic);
XSpeech = bsxfun(@minus, Mu, XSpeech);
XSpeech = bsxfun(@times, 1./Stdev, XSpeech);
%Do 4-fold cross-validation
C = zeros(2, 2);
for ii = 0:3
    testIdx = ii*NExamples/4 + (1:NExamples/4);
    trainIdx = 1:NExamples;
    trainIdx(testIdx) = -1;
    trainIdx = trainIdx(trainIdx > -1);
    svmStruct = svmtrain([XMusic(trainIdx, :); XSpeech(trainIdx, :)], ...
        [ones(length(trainIdx), 1); 2*ones(length(trainIdx), 1)]);
    for jj = 1:length(testIdx)
        class = svmclassify(svmStruct, XMusic(testIdx(jj), :));
        C(1, class) = C(1, class) + 1;
        class = svmclassify(svmStruct, XSpeech(testIdx(jj), :));
        C(2, class) = C(2, class) + 1;
    end
end
C
sum(diag(C))/sum(C(:))