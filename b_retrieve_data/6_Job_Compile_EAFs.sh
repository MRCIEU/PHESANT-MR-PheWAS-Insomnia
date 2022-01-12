#!/bin/bash
#SBATCH --job-name=compile_insomnia_eafs
#SBATCH --output=compile_insomnia_eafs_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=60:00:00
#SBATCH --mem=500M

#Put filepath in variable
DATA="${HOME}/scratch/InsomniaMRPheWAS/data/snp_stats"

#If the output file already exists delete it
if test -f $DATA/snp-stats-compiled.txt; then
        rm $DATA/snp-stats-compiled.txt
fi

#Re-create outputfile
touch  $DATA/snp-stats-compiled.txt

#Compile the snp data files for each chromosome into 1 file
cat $DATA/*-snp-stats.txt >> $DATA/snp-stats-compiled.txt

