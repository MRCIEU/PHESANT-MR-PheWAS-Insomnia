#!/bin/bash
#SBATCH --job-name=categorise
#SBATCH --output=categorise_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=20:00:00
#SBATCH --mem=100000M

#Put filepaths in variables
CODE="${HOME}/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/h_process_PHESANT"

#Load R
module add languages/r/4.0.2

#Run R scripts
cd $CODE
R CMD BATCH --no-save --no-restore categorise.R categorise_r_log.txt
R CMD BATCH --no-save --no-restore subcategorise.R subcategorise_r_log.txt
