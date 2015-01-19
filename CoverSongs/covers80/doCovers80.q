#!/bin/bash
#
#SBATCH --output=covers80Verbose.out
#SBATCH --mem-per-cpu=2000

/opt/apps/MATLAB/R2012b/bin/matlab -nodisplay -r "songIdx=$SLURM_ARRAY_TASK_ID;getCoversBeatSyncTDA_SGE;quit"

