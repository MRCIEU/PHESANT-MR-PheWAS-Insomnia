#!/bin/bash
#SBATCH --job-name=make_inputs_analysis2
#SBATCH --output=make_inputs__analysis2_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=20:00:00
#SBATCH --mem=10000M

##############################
# SET FILEPATHS AS VARIABLES #
##############################

DATA="${HOME}/scratch/InsomniaMRPheWAS/data"
INPUT="${HOME}/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/inputs/analysis2"

#########################
#     MAKE LOGORLIST    #
#########################

#Get alldataIDs, rsids, chromosome, position and alleles from snpstats file
awk '{ print$1,$4,$5,$6,$7 }' $DATA/all_snp_info-5.2.txt > $DATA/snpinfo23me.txt

#Take only wanted snps
grep -wFf $INPUT/SNPlist-analysis2.txt $DATA/snpinfo23me.txt > $DATA/analysis2/snpinfo23me-analysis2.txt

#Extract alldata IDs and rsids
awk '{ print$1,$2 }' $DATA/analysis2/snpinfo23me-analysis2.txt > $DATA/analysis2/rsids-analysis2.txt

#Extract alldata IDs
awk '{ print$1 }' $DATA/analysis2/snpinfo23me-analysis2.txt > $DATA/analysis2/IDs-analysis2.txt

#Extract alleles
awk '{ print$5 }' $DATA/analysis2/snpinfo23me-analysis2.txt > $DATA/analysis2/alleles-analysis2.txt

#Split every character of alleles column apart
sed -e 's/\(.\)/\1 /g' $DATA/analysis2/alleles-analysis2.txt > $DATA/analysis2/alleles-temp-analysis2.txt

#Take Allele B (effect allele) and allele A (non effect allele) leaving column of "\"s
awk '{ print$3,$1 }' $DATA/analysis2/alleles-temp-analysis2.txt > $DATA/analysis2/alleles-analysis2.txt
rm $DATA/analysis2/alleles-temp-analysis2.txt

#Re-attach seperated alleles with rsids
paste $DATA/analysis2/rsids-analysis2.txt $DATA/analysis2/alleles-analysis2.txt > $DATA/analysis2/snpinfo23me-analysis2.txt

#Sort by alldataID
sort -k 1 $DATA/analysis2/snpinfo23me-analysis2.txt > $DATA/analysis2/snpinfo23me-sort-analysis2.txt

#Remove alldata IDs
awk '{ print$2,$3,$4 }' $DATA/analysis2/snpinfo23me-sort-analysis2.txt > $DATA/analysis2/snpinfo23me-analysis2.txt
rm $DATA/analysis2/snpinfo23me-sort-analysis2.txt

#Take alldata ID, Pvalue, LogOR and stderr from GWAS summary data
awk '{ print$1,$3,$4,$5 }' $DATA/insomnia_broad.dat > $DATA/results23me.txt

#Take only wanted snps and sort by alldata IDs
awk 'NR==FNR{seen[$1]; next} $1 in seen' $DATA/analysis2/IDs-analysis2.txt $DATA/results23me.txt > $DATA/analysis2/results23me-temp-analysis2.txt
sort -k 1 $DATA/analysis2/results23me-temp-analysis2.txt > $DATA/analysis2/results23me-sort-analysis2.txt
awk '{ print$1,$3 }' $DATA/analysis2/results23me-sort-analysis2.txt > $DATA/analysis2/results23me-temp-analysis2.txt
rm $DATA/analysis2/results23me-sort-analysis2.txt

#Remove alldata IDs
awk '{ print$2 }' $DATA/analysis2/results23me-temp-analysis2.txt > $DATA/analysis2/results23me-analysis2.txt
rm $DATA/analysis2/results23me-temp-analysis2.txt

#Combine rsids/alleles with LogORs and sort by rsid
paste $DATA/analysis2/snpinfo23me-analysis2.txt $DATA/analysis2/results23me-analysis2.txt > $INPUT/LogORlist-temp-analysis2.txt
sort -k 1 $INPUT/LogORlist-temp-analysis2.txt > $INPUT/LogORlist-sort-analysis2.txt
rm $INPUT/LogORlist-temp-analysis2.txt

#Take all rsids and allele B frequencies for genotyped and imputed data
awk '{ print$2,$5 }' $DATA/gt_snp_stat-5.2.txt > $DATA/freq23me.txt
awk '{ print$2,$7 }' $DATA/im_snp_stat-5.2.txt > $DATA/freqimputed23me.txt

#Extract frequencies for snps from genotyped data
grep -wFf $INPUT/SNPlist-analysis2.txt $DATA/freq23me.txt > $DATA/analysis2/freq23me-analysis2.txt

#Take rsids from output to get list of genotyped snps
awk '{ print$1 }' $DATA/analysis2/freq23me-analysis2.txt > $DATA/analysis2/genotypedsnps-analysis2.txt

#Take everything but genotyped snps from SNPlist to get list of imputed snps
grep -vwFf $DATA/analysis2/genotypedsnps-analysis2.txt $INPUT/SNPlist-analysis2.txt > $DATA/analysis2/imputedsnps-analysis2.txt

#take frequncies for imputed snps and add onto frequencies for genotyped snps. Then sort by rsid.
grep -wFf $DATA/analysis2/imputedsnps-analysis2.txt $DATA/freqimputed23me.txt >> $DATA/analysis2/freq23me-analysis2.txt
sort -k 1 $DATA/analysis2/freq23me-analysis2.txt > $DATA/analysis2/freq23me-sort-analysis2.txt

#remove rsids
awk '{ print$2 }' $DATA/analysis2/freq23me-sort-analysis2.txt > $DATA/analysis2/freq23me-analysis2.txt
rm $DATA/analysis2/freq23me-sort-analysis2.txt

#combine with rest of data to make LogORlist
paste $INPUT/LogORlist-sort-analysis2.txt $DATA/analysis2/freq23me-analysis2.txt > $INPUT/LogORlist-temp-analysis2.txt
rm $INPUT/LogORlist-sort-analysis2.txt

#Add in headers 
sed  -i '1i rsID\tA1\tA2\tLogOR\tEAF' $INPUT/LogORlist-temp-analysis2.txt

#change whitespaces to tabs
sed -e 's/ /\t/g' $INPUT/LogORlist-temp-analysis2.txt > $INPUT/LogORlist-analysis2.txt
rm $INPUT/LogORlist-temp-analysis2.txt

