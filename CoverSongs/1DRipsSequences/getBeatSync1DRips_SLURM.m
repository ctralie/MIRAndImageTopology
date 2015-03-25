%Parameters from SLURM: songIdx, BeatsPerWin
javaclasspath('jars/tda.jar');
import api.*;
tda = Tda();

list1 = '../covers80/covers32k/list1.list';
files1 = textread(list1, '%s\n');
list2 = '../covers80/covers32k/list2.list';
files2 = textread(list2, '%s\n');

dirname = sprintf('AllRips%i', BeatsPerWin);
if ~exist(dirname)
    mkdir(dirname);
end

beatDownsample = 2;
ii = songIdx;
if (ii > 80)
    ii = ii - 80;
    filePrefix = files2{ii};
else
    filePrefix = files1{ii};
end
fprintf(1, 'Doing %s...\n', filePrefix);
DGMs = getBeatSync1DRips(filePrefix, BeatsPerWin, beatDownsample, tda);

save(sprintf('AllRips%i/%i.mat', BeatsPerWin, songIdx), 'DGMs');