# c_reformat_data
## Reformat Data into Dosages
### Run 7_Job_Code_Dosage.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/c_reformat_data/
sbatch 7_Job_Code_Dosage.sh
```
This runs `gen_to_expected.py` to code dosages (turning the three columns for each snp into one column containing the number of Allele Bs in each participant).
It uses the outputs from `4_Job_Compile_SNPs.sh` and outputs a file called `data/[analysis + number]/snps-dosage-[analysis + number].txt`.(No Analysis 2 as identical to Analysis 1).
It then deletes the first six columns of these files which contain the snp information (chromosome, id, rsid, base position, Allele A, Allele B) and outputs the file `data/[analysis + number]/snps-dosage2-[analysis + number].txt`. (No Analysis 2 as identical to Analysis 1).
## Transpose Data
### Run 8_Job_Transpose.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/c_reformat_data/
sbatch 8_Job_Transpose.sh
```
This runs `transpose.R` which transposes the final output of `8_Job_Transpose.sh` and takes rsids from the second last output of `8_Job_Transpose.sh` to use as column names.
It outputs the file `data/[analysis + number]/data-transposed-[analysis + number].txt`. (No Analysis 2 as identical to Analysis 1).
## Extract Gen and Phen IDs
### Input the following code directly into the command line
```
#Put paths in variables
GEN_DATA="$UK_B_LATEST/data/dosage_bgen"
PHEN_DATA="$APP_16729/2019-04-29/data"
DATA="${HOME}/scratch/InsomniaMRPheWAS/data"

#Copy genetic ID list
cp $GEN_DATA/data.chr1-22.sample $DATA/sample.txt

#Copy linker file
cp $PHEN_DATA/ieu_id_linker.csv $DATA/linker.txt
```
This gets the list of IDs for the genetic data (`$UK_B_LATEST/data/dosage_bgen/data.chr1-22.sample`)and the list of IDs for the Phenotype data (`$PHEN_DATA/ieu_id_linker.csv`).
## Add Gen and Phen IDs
### Run 9_Job_Add_IDs.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/c_reformat_data/
sbatch 9_Job_Add_IDs.sh
```
This adds the genetic and phenotype IDs to the transposed data.
This uses the output of `8_Job_Transpose.sh`, `data/sample.txt` and `data/linker.txt`.
It ouptuts `data/[analysis + number]/data-IDs-[analysis + number].txt`. (No Analysis 2 as identical to Analysis 1).
