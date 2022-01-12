#!/bin/bash
#SBATCH --job-name=code_dosage
#SBATCH --output=code_dosage_snps_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=60:00:00
#SBATCH --mem=10000M

##########################
# PUT PATHS In VARIABLES #
##########################

DATA="${HOME}/scratch/InsomniaMRPheWAS/data"
CODE="${HOME}/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/c_reformat_data"

###############
# CODE DOSAGE # 
###############

#Create a function called dosage. It's input is $1, what it does is stipulated below.
dosage() { 

	#Take the compiled gen data and pipes it into the python script which converts to dosage. 
	cat $DATA/$1/snps-compiled-"$1".gen | python $CODE/gen_to_expected.py > $DATA/$1/snps-dosage-"$1".txt

	#Remove the first 6 columns of the output which are not-needed snp information so the data can be transposed.
	cut -d' ' -f 7- $DATA/$1/snps-dosage-"$1".txt > $DATA/$1/snps-dosage2-"$1".txt

	#Count rows
	wc -l $DATA/$1/snps-dosage2-"$1".txt

	#Count column seperators
	head -n1 $DATA/$1/snps-dosage2-"$1".txt | grep -o " " | wc -l
} 

#Run for analysis 1 (identical to analysis 2). Output rows (snps) = 111. Output columns (participants) = 463005
dosage analysis1

#Copy for analysis 2
cp $DATA/analysis1/snps-dosage-analysis1.txt $DATA/analysis2/snps-dosage-analysis2.txt

#Run for analysis 3. Output rows (snps) = 129. Output columns (participants) = 463005 
dosage analysis3

