#!/bin/bash
#SBATCH --job-name=extract_insomnia_snps
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22 
#SBATCH --time=60:00:00
#SBATCH --mem=500M

################
# CREATE ARRAY #
################

#Tell Slurm to run the script multiple times simultaneously with all the values from 1 to 22 in the variable SLURM_ARRAY_TASK_ID. 
#This is used to simultaneously extract data from each chromosome.
#SBATCH --array=01-22
  
##########################
# PUT PATHS IN VARIABLES #
##########################

CHROM="$SLURM_ARRAY_TASK_ID"
GEN_DATA="$UK_B_LATEST/data/dosage_bgen"
DATA="${HOME}/scratch/InsomniaMRPheWAS/data"
INPUT="${HOME}/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/inputs"

###########
# Extract #
###########

#Create function called exctract_snps. what this function does is stipulated below ($1 is the input)
extract_snps() {

	#Load qctool
	module load apps/qctool/2.0rc4


	#If the array number is single digits...
	if [ $CHROM -lt 10 ] 
	then
		#...then extract the data from the chromosome file with that number after a 0...
		qctool -g $GEN_DATA/data.chr0"$CHROM".bgen -og $DATA/$1/snps_by_chrom/"$CHROM"-snps-"$1".gen -s $GEN_DATA/data.chr1-22.sample -incl-rsids $INPUT/$1/SNPlist-"$1".txt
	else
		#...otherwise just extract from the file with the array number
		qctool -g $GEN_DATA/data.chr"$CHROM".bgen -og $DATA/$1/snps_by_chrom/"$CHROM"-snps-"$1".gen -s $GEN_DATA/data.chr1-22.sample -incl-rsids $INPUT/$1/SNPlist-"$1".txt
	fi
}

#Extract 23andMe snps replicated in the meta analysis(identical for analysis 1 and 2).
extract_snps analysis1

#Extract snps for analysis3
extract_snps analysis3
