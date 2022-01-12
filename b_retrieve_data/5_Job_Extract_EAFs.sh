#!/bin/bash
#SBATCH --job-name=extract_insomnia_eafs
#SBATCH --output=extract_insomnia_eafs_slurm.txt
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
SNP_DATA="$UK_B_LATEST/data/snp-stats"
DATA="${HOME}/scratch/InsomniaMRPheWAS/data"

###########
# EXTRACT #
###########

#If the array number is single digit...
if [ $CHROM -lt 10 ] 
then
	#...then extract EAFs from the chromosome file with this number coming after a 0...
	awk '{if (NR>15) print $2,$13}' $SNP_DATA/data.chr0"$CHROM".snp-stats > $DATA/snp_stats/"$CHROM"-snp-stats.temp.txt
else
	#...otherwise extract from file with the array number
	awk '{if (NR>15) print $2,$13}' $SNP_DATA/data.chr"$CHROM".snp-stats > $DATA/snp_stats/"$CHROM"-snp-stats.temp.txt
fi

#Delete first and last line of each output
awk 'NR>2 {print last} {last=$0}' $DATA/snp_stats/"$CHROM"-snp-stats.temp.txt > $DATA/snp_stats/"$CHROM"-snp-stats.txt

#Delete temp file 
rm $DATA/snp_stats/"$CHROM"-snp-stats.temp.txt

