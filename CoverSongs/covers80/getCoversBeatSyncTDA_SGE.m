%Compute the beat-synchronous TDA, and also compute many 30ms MFCCs
%function [] = getBeatSyncTDA_SGE(songIdx)
DOPLOT = 0;
try
    files = textread('allfiles.list', '%s\n');
    filename = sprintf('BeatsAndOggs/%s.ogg', files{songIdx});
    beatsFilename = sprintf('BeatsAndOggs/%s.mat', files{songIdx});
    fprintf(1, 'Doing %s...\n', files{songIdx});
    
    
    bts = load(beatsFilename);
    bts = bts.bts;    
    [ MFCCs, Fs, SampleDelays, PointClouds, Is, LEigs, TimeLoopHists, bts ] = ...
        getBeatSyncShapeFeatures( filename, bts, DOPLOT );
    
    save(sprintf('ftrsgeom/%s.mat', files{songIdx}),  ...
        'LEigs', 'Is', 'bts', 'SampleDelays', 'Fs', 'TimeLoopHists', 'MFCCs', 'PointClouds');
catch err
   err
end

%end
