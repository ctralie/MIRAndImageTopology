%Drop in Ellis's covers80 code with whatever he did
function [ ChromaAvg ] = getBeatSyncChromaMatrixEllis( sprefix )
    addpath('../../');
    addpath('../covers80/src');
    song = load(['../covers80/TempoEmbeddings/', sprefix, '.mat']);
    [X, Fs] = audioread(['../covers80/covers32k/', sprefix, '.mp3']);
    ChromaAvg = mychrombeatftrs(X, Fs, song.bts)';
end

