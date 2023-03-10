#!/bin/bash
#SBATCH --account=psyc010162
#SBATCH --job-name=forest_plot
#SBATCH --output=forest_plot_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=10:00:00
#SBATCH --mem=10000M

#Put filepaths in variables
CODE="${HOME}/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/i_follow_up"
DATA="${HOME}/scratch/InsomniaMRPheWAS/data"

################
# Run Followup #
################

cd $CODE

#Load R
module add languages/r/4.0.2

#Run R scripts
cd $CODE
R CMD BATCH --no-save --no-restore forest_plot.R forest_plot_r_log.txt
