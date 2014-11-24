function [] = makeBeatsAudio( fileprefix )
    [X, Fs] = audioread(sprintf('%s.au', fileprefix));
    bts = load(sprintf('%s.mat', fileprefix));
    blip = cos(2*pi*440*(1:200)/Fs);
    for ii = 1:length(bts.onsets)
        idx = round(bts.onsets(ii)*Fs);
        X(idx:idx+length(blip)-1) = blip;
    end
    audiowrite(sprintf('%s.ogg', fileprefix), X, Fs);
end

