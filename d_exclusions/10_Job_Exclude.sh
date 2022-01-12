#!/bin/bash
#SBATCH --job-name=exclude_non_white_british
#SBATCH --output=exclude_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=20:00:00
#SBATCH --mem=10000M

#Put path in variable
CODE="${HOME}/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/d_exclusions"

#Load R
module add languages/r/4.0.2

#Run R script
cd $CODE
R CMD BATCH --no-save --no-restore exclude.R exclude_r_log.txt

#Copy output for analysis 1 and for analysis 2 (as identical)
cp $HOME/scratch/InsomniaMRPheWAS/data/analysis1/data-excld-analysis1.txt $HOME/scratch/InsomniaMRPheWAS/data/analysis2/data-excld-analysis2.txt

