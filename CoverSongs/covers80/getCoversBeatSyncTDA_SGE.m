%Compute the beat-synchronous TDA, and also compute many 30ms MFCCs
%function [] = getBeatSyncTDA_SGE(songIdx)
DOPLOT = 0;
try
    javaclasspath('jars/tda.jar');
    import api.*;
    tda = Tda();
            
    files = textread('allfiles.list', '%s\n');
    filename = sprintf('BeatsAndOggs/%s.ogg', files{songIdx});
    beatsFilename = sprintf('BeatsAndOggs/%s.mat', files{songIdx});
    fprintf(1, 'Doing %s...\n', files{songIdx});
    
    
    bts = load(beatsFilename);
    bts = bts.bts;
    for BtsWin = [2, 4, 8]
        fprintf(1, 'Doing BtsWin = %i...\n', BtsWin);
		[ MFCCs, Fs, SampleDelays, PointClouds, IsRips, IsMorse, Dists, LEigs, TimeLoopHists, bts ] = ...
		    getBeatSyncShapeFeatures( tda, filename, bts, DOPLOT );
		save(sprintf('ftrsgeom/%s_%i.mat', files{songIdx}, BtsWin),  ...
		    'LEigs', 'IsRips', 'IsMorse', 'Dists', 'bts', 'SampleDelays', 'Fs', 'TimeLoopHists', 'MFCCs', 'PointClouds');
	end
catch err
   err
end

%end
