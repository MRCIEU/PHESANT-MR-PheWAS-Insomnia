#!/bin/bash
#SBATCH --job-name=search
#SBATCH --output=search_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=10:00:00
#SBATCH --mem=5000M

#Put filepaths in variables
CODE="${HOME}/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/i_follow_up"

#Load R
module add languages/r/4.0.2

#Run R scripts
cd $CODE
R CMD BATCH --no-save --no-restore search.R search_r_log.txt
