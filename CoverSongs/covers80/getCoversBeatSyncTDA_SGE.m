%Compute the beat-synchronous TDA, and also compute many 30ms MFCCs
function [] = getCoversBeatSyncTDA_SGE(songIdx, tda)
    DOPLOT = 0;
    files = textread('allfiles.list', '%s\n');
    filename = sprintf('BeatsAndOggs/%s.ogg', files{songIdx});
    beatsFilename = sprintf('BeatsAndOggs/%s.mat', files{songIdx});
    fprintf(1, 'Doing %s...\n', files{songIdx});
    
    
    bts = load(beatsFilename);
    bts = bts.bts;
    for BtsWin = 2
        outfilename = sprintf('ftrsgeomchroma/%s_%i.mat', files{songIdx}, BtsWin);
        if exist(outfilename)
            fprintf(1, 'Skipping %s\n', outfilename);
            continue;
        end
        fprintf(1, 'Doing %s BtsWin = %i...\n', files{songIdx}, BtsWin);
		[ MFCCs, Fs, SampleDelays, PointClouds, IsRips, IsMorse, Dists, LEigs, TimeLoopHists, bts ] = ...
		    getBeatSyncShapeFeaturesChroma( tda, filename, bts, DOPLOT, BtsWin );
		save(outfilename,  ...
		    'LEigs', 'IsRips', 'IsMorse', 'Dists', 'bts', 'SampleDelays', 'Fs', 'TimeLoopHists', 'MFCCs', 'PointClouds', 'BtsWin');
    end

end
