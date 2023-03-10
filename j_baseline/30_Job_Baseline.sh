#!/bin/bash
#SBATCH --job-name=baseline
#SBATCH --output=baseline_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=10:00:00
#SBATCH --mem=10000M

#Put filepaths in variables
CODE="${HOME}/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/j_baseline"
DATA="${HOME}/scratch/InsomniaMRPheWAS/data"

############
# GET DATA #
############

#Sex
head -n1 $DATA/data.43017.phesant.tab | sed 's/\t/\n/g' | nl | grep -wn "x31_0_0"
#11

#Townsend
head -n1 $DATA/data.43017.phesant.tab | sed 's/\t/\n/g' | nl | grep -wn "x189_0_0"
#414

#Insomnia
head -n1 $DATA/data.43017.phesant.tab | sed 's/\t/\n/g' | nl | grep -wn "x1200_0_0"
#841

#Education
head -n1 $DATA/data.43017.phesant.tab | sed 's/\t/\n/g' | nl | grep -n "x6138_0_"
#4284

#Age
head -n1 $DATA/data.43017.phesant.tab | sed 's/\t/\n/g' | nl | grep -wn "x21022_0_0"
#8817

#Extract confounder
cut -f1,11,414,841,4284,8817 $DATA/data.43017.phesant.tab > $DATA/baseline.txt
head -n1 $DATA/baseline.txt

#Change headers
sed -i 1d $DATA/baseline.txt
sed -i '1i eid\tSex\tTownsend\tInsomnia\tEducation\tAge' $DATA/baseline.txt


####################
# GET DESCRIPTIVES #
####################

cd $CODE

#Load R
module add languages/r/4.0.2

#Run R scripts
cd $CODE
R CMD BATCH --no-save --no-restore baseline.R baseline_r_log.txt
