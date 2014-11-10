function [bts] = getBeatsOverlayedAudio( fileprefix, skipLength )
    if nargin < 2
        skipLength = 1;
    end
    [X, Fs] = audioread(sprintf('../mp3s-32k/%s.mp3', fileprefix));
    chromftrs = load(sprintf('../chromftrs/%s.mat', fileprefix));
    bts = chromftrs.bts;
    blipLen = 200;
    blip = cos( (440*2*pi/Fs)*(1:blipLen) );
    for ii = 1:skipLength:length(bts)-1
        beat = (bts(ii) + bts(ii+1))/2;
        istart = round(beat*Fs) - blipLen/2;
        X(istart:istart+blipLen-1) = blip;
    end
    fileparts = strsplit(fileprefix, '/');
    outname = fileparts{1};
    for ii = 2:length(fileparts)
        outname = sprintf('%s_%s', outname, fileparts{ii});
    end
    outname = sprintf('%s.ogg', outname)
    audiowrite(outname, X, Fs);
end