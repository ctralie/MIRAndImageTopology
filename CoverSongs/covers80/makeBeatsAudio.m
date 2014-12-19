function [] = makeBeatsAudio( filePrefix, btsin )
    [X, Fs] = audioread(sprintf('covers32k/%s.mp3', filePrefix));
    if nargin < 2
        bts = load(sprintf('covers32k/%s.mat', filePrefix));
    else
        bts.onsets = btsin;
    end
    blip = cos(2*pi*440*(1:200)/Fs);
    for ii = 1:length(bts.onsets)
        idx = round(bts.onsets(ii)*Fs);
        X(idx:idx+length(blip)-1) = blip;
    end
    audiowrite(sprintf('covers32k/%s.ogg', filePrefix), X, Fs);
end

