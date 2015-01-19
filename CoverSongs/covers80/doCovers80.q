#!/bin/tcsh
#
#$ -S /bin/tcsh -cwd
#$ -o artistBeatSyncVerbose.out -j y
#$ -l mem_free=4G

/opt/apps/MATLAB/R2012b/bin/matlab -nodisplay -r "songIdx=$SGE_TASK_ID;getCoversBeatSyncTDA_SGE;quit"

