#!/bin/tcsh
#
#$ -S /bin/tcsh -cwd
#$ -o artistVerbose.out -j y
#$ -l mem_free=4G
cd /home/username/seq/simple
matlab -nodisplay -r "ii=$SGE_TASK_ID;computeArtist20TDAFeatures_SGE;quit"

