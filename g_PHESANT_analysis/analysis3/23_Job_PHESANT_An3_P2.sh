#!/bin/bash
#SBATCH --job-name=PHESANT_An3_P2_insomnia
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=20 
#SBATCH --time=120:00:00
#SBATCH --mem=100000M

#Run the script multiple times simultaneously with all the values from 101 to 200 in the variable SLURM_ARRAY_TASK_ID.
#SBATCH --array=101-200

#Load R
module add languages/r/4.0.2

#Print date
date

#Put filepaths in variables
DATA="${HOME}/scratch/InsomniaMRPheWAS/data/"
OUTPUT="${HOME}/scratch/InsomniaMRPheWAS/output/analysis3/PHESANT/"
CODE="${HOME}/scratch/PHESANT/WAS/"
VARLIST="${HOME}/scratch/PHESANT/variable-info/"
outcomeFile="${DATA}data.43017.phesant.tab"
expFile="${DATA}analysis3/scores-PHESANT-analysis3.csv"
varListFile="${VARLIST}outcome-info.tsv"
dcFile="${VARLIST}data-coding-ordinal-info.txt"
confFile="${DATA}confounders.csv"

#Put array number into new variable to be used in PHESANT and specify total number of parts (200)
pIdx="$SLURM_ARRAY_TASK_ID"
np=200

#Run the second part of PHESANT using array to split it into 100 parallel parts.
cd $CODE
Rscript phenomeScan.r --partIdx=$pIdx --numParts=$np --phenofile=${outcomeFile} --tab=TRUE --traitofinterestfile=${expFile} --variablelistfile=${varListFile} --datacodingfile=${dcFile} --traitofinterest="scores" --resDir=${OUTPUT} --userId="eid" --confounderfile=${confFile} --mincase=100

#Print date
date
