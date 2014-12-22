%Programmer: Chris Tralie
%Purpose: 
function [] = makeBeatsAudio( genre, num )
    [X, Fs] = audioread(sprintf('genres/%s/%s.%.5i.au', genre, genre, num));
    bts = load(sprintf('TzanetakisBeats/%s/%s.%.5i.mat', genre, genre, num));
    blip = cos(2*pi*440*(1:200)/Fs);
    for ii = 1:length(bts.onsets)
        idx = round(bts.onsets(ii)*Fs);
        X(idx:idx+length(blip)-1) = blip;
    end
    audiowrite(sprintf('genres/%s/%s.%.5i.ogg', genre, genre, num), X, Fs);
end

