# b_retrieve_data
## Extract SNPs
### Run 3_Job_Extract_SNPs.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/b_retrieve_data/
sbatch 3_Job_Extract_SNPs.sh
``` 
This extracts the relevant snps from the UK Biobank genetic data from the `$UK_B_LATEST/data/dosage_bgen` folder using the `SNPlist-` files in the `code/PHESANT-MR-PheWAS-Insomnia/inputs` folder) and creates an output file for each chromosome in the `data/[analysis + number]/snps_by_chrom/` folder. i.e `[chromosome number]-snps-[analysis + number].gen`.(No Analysis 2 as identical to Analysis 1).
### Run 4_Job_Compile_SNPs.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/b_retrieve_data/
sbatch 4_Job_Compile_SNPs.sh
```
This compiles the outputs created for each chromosome into the a file called `data/[analysis + number]/snps-compiled-[analysis + number].gen`. (No Analysis 2 as identical to Analysis 1).
## Exctract UK_Biobank Effect Allele Frequencies
### Run 5_Job_Extract_EAFs.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/b_retrieve_data/
sbatch 5_Job_Extract_EAFs.sh
```
This extracts the rsid column and allele B frequency columns from the UK Biobank snp-stats data from the `$UK_B_LATEST/data/snp-stats` folder, deletes all rows which aren't part of the data, and creates and outputs a file for each chromosome. i.e. `data/snp-stats/[chromosome number]-snp-stats.txt`.
### Run 6_Job_Compile_EAFs.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/b_retrieve_data/
sbatch 6_Job_Compile_EAFs.sh
```
This compiles the outputs created for each chromosome into one file called `data/snp_stats/snp-stats-compiled.txt`.
### Input the following code directly into the command line
```
#Put filepaths in variables
INPUT="${HOME}/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/inputs"
DATA="${HOME}/scratch/InsomniaMRPheWAS/data"

#Extract relevant snp columns using grep and snplist for analysis1
grep -wFf $INPUT/analysis1/SNPlist-analysis1.txt $DATA/snp_stats/snp-stats-compiled.txt > $DATA/analysis1/EAF-analysis1.txt

#Count rows of outups (i.e. 111 snps)
wc -l $DATA/analysis1/EAF-analysis1.txt

#Copy for analysis2
cp $DATA/analysis1/EAF-analysis1.txt $DATA/analysis2/EAF-analysis2.txt

#Extract relevant snp columns using grep and snplist for analysis3
grep -wFf $INPUT/analysis3/SNPlist-analysis3.txt $DATA/snp_stats/snp-stats-compiled.txt > $DATA/analysis3/EAF-analysis3.txt

#Count rows of outups (i.e. 129 snps)
wc -l $DATA/analysis3/EAF-analysis3.txt
```
This extracts the rows for the relevant SNPs using grep and the SNPlists and creates the file `data/[analysis + number]/EAF-[analysis + number].txt`.
