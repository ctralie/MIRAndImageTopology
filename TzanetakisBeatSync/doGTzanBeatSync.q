#!/bin/tcsh
#
#$ -S /bin/tcsh -cwd
#$ -o GTzanBeatSyncVerbose.out -j y
#$ -l mem_free=4G

/opt/apps/MATLAB/R2012b/bin/matlab -nodisplay -r "songindex=$SGE_TASK_ID;getGTzanBeatSyncTDA_SGE;quit"

