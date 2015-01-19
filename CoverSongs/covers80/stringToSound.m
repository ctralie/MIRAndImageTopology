%C: Codebook to use
%fileinprefix: File to use to pick example sounds close to the codebook
%elements in C
%fileoutprefix: The file to replace with codebook elements
function [] = stringToSound( C, fileinprefix, fileoutprefix, outname )
    [XIn, Fs] = audioread(sprintf('covers32k/%s.mp3', fileinprefix));
    beatsIn = load(sprintf('BeatsAndOggs/%s.mat', fileinprefix));
    beatsIn = round(Fs*beatsIn.bts);
    
    xrangeLandscape = linspace(0, 2, 50);
    yrangeLandscape = linspace(0, 0.6, 50);
    feats = load(sprintf('ftrsgeom/%s.mat', fileoutprefix));
    str = getBeatShapeString(feats.Is, C, xrangeLandscape, yrangeLandscape);
    
    %Use the closest elements in the input as sounds for the output
    feats = load(sprintf('ftrsgeom/%s.mat', fileinprefix));
    [~, CReps] = getBeatShapeString(feats.Is, C, xrangeLandscape, yrangeLandscape);
    XReps = cell(1, size(C, 1));
    for ii = 1:size(C, 1)
        if (CReps(ii) < length(beatsIn) - 1)
            interval = beatsIn(CReps(ii)):beatsIn(CReps(ii)+2);
        else
            interval = beatsIn(Creps(ii)):length(XIn);
        end
        XReps{ii} = XIn(interval);
        audiowrite(sprintf('Rep%i.ogg', ii), XReps{ii}, Fs);
    end
    
    XOut = [];
    for ii = 1:2:length(str)
        XOut = [XOut; XReps{str(ii)}(:)];
    end
    audiowrite(outname, XOut, Fs);
end