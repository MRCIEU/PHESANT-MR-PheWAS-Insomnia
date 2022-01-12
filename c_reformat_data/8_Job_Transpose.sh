#!/bin/bash
#SBATCH --job-name=transpose
#SBATCH --output=transpose_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=60:00:00
#SBATCH --mem=10000M

#Put path in variable
CODE="${HOME}/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/c_reformat_data"

#Load R
module add languages/r/4.0.2

#Run R script
cd $CODE
R CMD BATCH --no-save --no-restore transpose.R transpose_r_log.txt

