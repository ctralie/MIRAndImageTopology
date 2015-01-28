function [ beatString1, beatString2, score, alignment ] = matchSongs( s1prefix, s2prefix, outname )
    C = load('KMeans4.mat');
    C = C.C;
    xrangeLandscape = linspace(0, 2, 50);
    yrangeLandscape = linspace(0, 0.6, 50);
    feats1 = load(sprintf('ftrsgeom/%s.mat', s1prefix));
    feats2 = load(sprintf('ftrsgeom/%s.mat', s2prefix));
    beatString1 = getBeatShapeString(feats1.IsRips, C, xrangeLandscape, yrangeLandscape);
    beatString2 = getBeatShapeString(feats2.IsRips, C, xrangeLandscape, yrangeLandscape);
    
    
    SMatch = 2;
    SMismatch = -3;
    GapOpen = 2;
    ExtendGap = 2;
    SMatrix = SMatch*eye(size(C, 1)) - SMismatch;
    SMatrix = SMatrix + SMismatch;    
    [score, alignment] = nwalign(beatString1, beatString2, ...
        'ScoringMatrix', SMatrix, 'GapOpen', GapOpen, 'ExtendGap', ExtendGap, 'Showscore', true);
    save(outname, 'beatString1', 'beatString2', 'score', 'alignment');
end