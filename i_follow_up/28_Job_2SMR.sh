#!/bin/bash
#SBATCH --job-name=2SMR
#SBATCH --output=2SMR_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=10:00:00
#SBATCH --mem=10000M

#Put filepaths in variables
CODE="${HOME}/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/i_follow_up"
DATA="${HOME}/scratch/InsomniaMRPheWAS/data"

#Load R
module add languages/r/4.0.2

#Run R scripts
cd $CODE
R CMD BATCH --no-save --no-restore 2smr.R 2smr_r_log.txt
