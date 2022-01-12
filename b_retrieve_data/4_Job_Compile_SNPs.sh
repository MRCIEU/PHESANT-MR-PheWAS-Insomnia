#!/bin/bash
#SBATCH --job-name=compile_insomnia_snps
#SBATCH --output=compile_insomnia_snps_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22 
#SBATCH --time=60:00:00
#SBATCH --mem=100M

#Put filpath in variable
DATA="${HOME}/scratch/InsomniaMRPheWAS/data"

#Create a function called compile_snps. what it does is stipulated below. $1 refers to the input.
compile_snps() {

	#If the output file already exists remove it
	if test -f $DATA/$1/snps-compiled-"$1".gen; then
		rm $DATA/$1/snps-compiled-"$1".gen
	fi 

	#Re-create empty output file
	touch $DATA/$1/snps-compiled-"$1".gen

	#Add the gen data for each chromosome to the final output.
	cat $DATA/$1/snps_by_chrom/*snps-"$1".gen >> $DATA/$1/snps-compiled-"$1".gen

	#Count rows
	wc -l $DATA/$1/snps-compiled-"$1".gen

	#count column seperators
	head -n1 $DATA/$1/snps-compiled-"$1".gen | grep -o " " | wc -l
}

#Run for analysis 1 (identical to 2). Output rows (no. of snps) = 111. Number of subjects (three columns per subject) = 463005 
compile_snps analysis1

#Run for analysis 3. Output rows (no. of snps) = 129. Number of subjects (three columns per subject) = 463005
compile_snps analysis3
