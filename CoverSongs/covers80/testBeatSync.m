files = textread('covers32k/allfiles.list', '%s\n');
addpath(genpath('src'));

ii = 2;
files{ii}
filepath = ['covers32k/', files{ii}, '.mp3'];
[X, Fs] = audioread(filepath);
[F, bts] = chrombeatftrs(X, Fs);
%bts = bts(1:2:end);
%makeBeatsAudio(files{ii}, bts);
[AllSampleDelays, Ds] = localMFCCBeats(X, Fs, bts);
