#!/bin/bash
#SBATCH --job-name=PHESANT_An2_P3_insomnia
#SBATCH --output=PHESANT_An2_P3_insomnia.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=20 
#SBATCH --time=60:00:00
#SBATCH --mem=1000M

#Load R
module add languages/r/4.0.2

#Put filepaths in variables
VARLIST="${HOME}/scratch/PHESANT/variable-info/"
OUTPUT="${HOME}/scratch/InsomniaMRPheWAS/output/analysis2/PHESANT/"
CODE="${HOME}/scratch/PHESANT/resultsProcessing/"
varListFile="${VARLIST}outcome-info.tsv"

#Run R script
cd $CODE
Rscript mainCombineResults.r --resDir=${OUTPUT} --numParts=200 --variablelistfile=${varListFile}
