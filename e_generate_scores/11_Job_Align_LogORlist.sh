#!/bin/bash
#SBATCH --job-name=align_logORlist
#SBATCH --output=align_logORlist_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=20:00:00
#SBATCH --mem=1000M

#Put path in variable
CODE="${HOME}/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/e_generate_scores"

#Load R
module add languages/r/4.0.2
#Loads R

#Run R script
cd $CODE
R CMD BATCH --no-save --no-restore align_logORlist.R align_logORlist_r_log.txt

