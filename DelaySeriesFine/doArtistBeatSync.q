#!/bin/tcsh
#
#$ -S /bin/tcsh -cwd
#$ -o artistBeatSyncVerbose.out -j y
#$ -l mem_free=4G

matlab -nodisplay -r "songindex=$SGE_TASK_ID;getArtist20BeatSyncTDA_SGE;quit"

