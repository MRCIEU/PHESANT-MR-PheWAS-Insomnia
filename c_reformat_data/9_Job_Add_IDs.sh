#!/bin/bash
#SBATCH --job-name=add_IDs
#SBATCH --output=add_IDs_slurm.txt
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
R CMD BATCH --no-save --no-restore add_IDs.R add_IDs_r_log.txt

