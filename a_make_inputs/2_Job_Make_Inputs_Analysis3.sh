#!/bin/bash
#SBATCH --job-name=make_inputs_analysis3
#SBATCH --output=make_inputs__analysis3_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=20:00:00
#SBATCH --mem=10000M

##############################
# SET FILEPATHS AS VARIABLES #
##############################

DATA="${HOME}/scratch/InsomniaMRPheWAS/data"
INPUT="${HOME}/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/inputs/analysis3"
CODE="${HOME}/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/a_make_inputs"

###########################
#  PREPARE FOR CLUMPING   #
###########################

#Combine snpinfo and results
paste $DATA/snpinfo23me.txt $DATA/results23me.txt > $DATA/inforesults23me.txt

#take only significant rows
awk '$7<0.00000005' $DATA/inforesults23me.txt > $DATA/unclumpedsnps.txt

#Just take those from 22 standard chromosomes
grep 'chr1\|chr2\|chr3\|chr4\|chr5\|chr6\|chr7\|chr8\|chr9\|chr10\|chr11\|chr12\|chr13\|chr14\|chr15\|chr16\|chr17\|chr18\|chr19\|chr20\|chr21\|chr22' $DATA/unclumpedsnps.txt > $DATA/unclumpedsnps-temp.txt

#Remove alldata IDs
awk '{ print$2,$3,$4,$5,$7,$8,$9 }' $DATA/unclumpedsnps-temp.txt > $DATA/unclumpedsnps.txt

#Change headers for Clump_data
sed  -i '1i SNP chr_name chrom_start alleles pval.exposure effect se' $DATA/unclumpedsnps.txt

###############
#    CLUMP    #
###############

#Load R
module add languages/r/4.0.2

#Run R code
cd $CODE
R CMD BATCH --no-save --no-restore clump.R clump_r_log.txt

#Remove last column and replace rs28458909 with proxy
awk 'NF{--NF};1' $DATA/clumpedsnps.txt > $DATA/clumpedsnps-temp.txt
mv $DATA/clumpedsnps-temp.txt $DATA/clumpedsnps.txt
sed -i 's!rs28458909 chr9 140257189 C/T 5.29853e-12 0.0380876 0.00551371!rs28780988 chr9 140258412 A/C 5.33928e-12 -0.0380794 0.00551340!g' $DATA/clumpedsnps.txt

###############
#   PROCESS   #
###############

#Take just lead SNPs to make SNPlist
awk '{ print$1 }' $DATA/clumpedsnps.txt > $INPUT/SNPlist-temp-analysis3.txt

#Remove header from list of lead snps
sed '1d' $INPUT/SNPlist-temp-analysis3.txt > $INPUT/SNPlist-analysis3.txt
rm $INPUT/SNPlist-temp-analysis3.txt

#Take alleles
awk '{ print$4 }' $DATA/clumpedsnps.txt > $DATA/analysis3/alleles-temp-analysis3.txt

#Delete header
sed '1d' $DATA/analysis3/alleles-temp-analysis3.txt > $DATA/analysis3/alleles-analysis3.txt

#split every character of alleles column apart
sed -e 's/\(.\)/\1 /g' $DATA/analysis3/alleles-analysis3.txt > $DATA/analysis3/alleles-temp-analysis3.txt

#Take Allele B (effect allele) and allele A (non effect allele) leaving column of "\"s
awk '{ print$3,$1 }' $DATA/analysis3/alleles-temp-analysis3.txt > $DATA/analysis3/alleles-analysis3.txt
rm $DATA/analysis3/alleles-temp-analysis3.txt

#Get LogORs
awk '{ print$6 }' $DATA/clumpedsnps.txt > $DATA/analysis3/results23me-temp-analysis3.txt

#Delete header
sed '1d' $DATA/analysis3/results23me-temp-analysis3.txt > $DATA/analysis3/results23me-analysis3.txt
rm $DATA/analysis3/results23me-temp-analysis3.txt

#Re-attach seperated alleles with rsids
paste $INPUT/SNPlist-analysis3.txt $DATA/analysis3/alleles-analysis3.txt $DATA/analysis3/results23me-analysis3.txt > $INPUT/LogORlist-temp-analysis3.txt
sort -k 1 $INPUT/LogORlist-temp-analysis3.txt > $INPUT/LogORlist-sort-analysis3.txt

#Extract frequecies for lead snps from genotyped data
grep -wFf $INPUT/SNPlist-analysis3.txt $DATA/freq23me.txt > $DATA/analysis3/freq23me-analysis3.txt

#Take rsids from output to get list of genotyped snps
awk '{ print$1 }' $DATA/analysis3/freq23me-analysis3.txt > $DATA/analysis3/genotypedsnps-analysis3.txt

#Take everything but genotyped snps from SNPlist to get list of imputed snps
grep -vwFf $DATA/analysis3/genotypedsnps-analysis3.txt $INPUT/SNPlist-analysis3.txt > $DATA/analysis3/imputedsnps-analysis3.txt

#Take frequncies for imputed snps and add onto frequencies for genotyped snps. Then sort by rsid.
grep -wFf $DATA/analysis3/imputedsnps-analysis3.txt $DATA/freqimputed23me.txt >> $DATA/analysis3/freq23me-analysis3.txt
sort -k 1 $DATA/analysis3/freq23me-analysis3.txt > $DATA/analysis3/freq23me-sort-analysis3.txt

#Remove rsids
awk '{ print$2 }' $DATA/analysis3/freq23me-sort-analysis3.txt > $DATA/analysis3/freq23me-analysis3.txt
rm $DATA/analysis3/freq23me-sort-analysis3.txt

#Combine rsids/alleles with LogOrs and frequencies
paste $INPUT/LogORlist-sort-analysis3.txt $DATA/analysis3/freq23me-analysis3.txt > $INPUT/LogORlist-temp-analysis3.txt
rm $INPUT/LogORlist-sort-analysis3.txt

#Get SEs
awk '{ print$7 }' $DATA/clumpedsnps.txt > $DATA/analysis3/SEs23me.txt

#Make Exposure MR Data
paste $INPUT/LogORlist-temp-analysis3.txt $DATA/analysis3/SEs23me.txt > $INPUT/exposure_data.txt

#Add in headers
sed  -i '1i rsID\tA1\tA2\tLogOR\tEAF' $INPUT/LogORlist-temp-analysis3.txt
sed  -i '1i SNP\teffect_allele\tother_allele\tbeta\teaf\tse' $INPUT/exposure_data.txt

#Change whitespaces to tabs
sed -e 's/ /\t/g' $INPUT/LogORlist-temp-analysis3.txt > $INPUT/LogORlist-analysis3.txt
sed -i 's/ /\t/g' $INPUT/exposure_data.txt
rm $INPUT/LogORlist-temp-analysis3.txt

#Replace rsid for rs28780988 with positional id as rsid not in UK Biobank
sed -i 's/rs28780988/9:140258412_C_A/g' $INPUT/SNPlist-analysis3.txt
sed -i 's/rs28780988\tC\tA\t-0.0380794\t0.87931/9:140258412_C_A\tC\tA\t-0.0380794\t0.87931/g' $INPUT/LogORlist-analysis3.txt
