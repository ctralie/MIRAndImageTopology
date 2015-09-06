hopSize = 512;
NWin = 43;

NFiles = 64;
musicFiles = strsplit(ls('music_wav'));
musicFiles = musicFiles(1:NFiles);
speechFiles = strsplit(ls('speech_wav'));
speechFiles = speechFiles(1:NFiles);
files = cell(1, NFiles*2);
labels = cell(1, NFiles*2);
for ii = 1:NFiles
    files{ii} = sprintf('music_wav/%s', musicFiles{ii});
    labels{ii} = 'music';
end
for ii = 1:NFiles
    files{NFiles+ii} = sprintf('speech_wav/%s', speechFiles{ii});
    labels{NFiles+ii} = 'speech';
end

[XAudio, Fs] = audioread(files{ii});
if size(XAudio, 2) > 1
    XAudio = mean(XAudio, 2);
end
[DelaySeries, Fs, SampleDelays, FeatureNames] = getDelaySeriesFeatures(XAudio, Fs, hopSize, 1, NWin, 20);
fout = fopen('MusicSpeech.arff', 'w');
fprintf(fout, '@relation MusicSpeech.arff\n');
for ii = 1:length(FeatureNames)
    fprintf(fout, '@attribute MEAN_%s real\n', FeatureNames{ii});
end
for ii = 1:length(FeatureNames)
    fprintf(fout, '@attribute STD_%s real\n', FeatureNames{ii});
end
fprintf(fout, '@attribute type {music, speech}\n');
fprintf(fout, '@data\n');

Xs = zeros(length(files), size(DelaySeries, 2)*2);
for ii = 1:length(files)
    ii
    [XAudio, Fs] = audioread(files{ii});
    if size(XAudio, 2) > 1
        XAudio = mean(XAudio, 2);
    end
    XAudio = XAudio/std(abs(XAudio)); %Primitive loudness normalization
    X = getDelaySeriesFeatures(XAudio, Fs, hopSize, 1, NWin, 20);
    X = [mean(X) std(X)];
    Xs(ii, :) = X;
    for kk = 1:length(X)
        fprintf(fout, '%g, ', X(kk));
    end
    fprintf(fout, '%s\n', labels{ii});
end
fclose(fout);
save('MusicSpeech.mat', 'Xs', 'files');