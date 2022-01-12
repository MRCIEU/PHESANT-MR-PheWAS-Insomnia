# e_generate_scores
## Align and Process LogORlists
### Run 11_Job_Align_LogORlist.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/e_generate_scores/
sbatch 11_Job_Align_LogORlist.sh
```
This runs `align_LogORlist.R` which identifies whether the effect alleles in the LogORlist increase or decrease risk of insomnia and re-aligns them all to have a positive association.
This uses the `LogORlist-[analysis + number].txt` in the `code/PHESANT-MR-PheWAS-Insomnia/inputs/[analysis + number]` folder).
it outputs:
```
code/inputs/[analysis + number]/LogORlist-aligned-[analysis + number].txt
code/inputs/[analysis + number]/LogORlist-direction-[analysis + number].txt
```
## Categorise UKB SNPs 
### Run 12_Job_Categorise_UKB_SNPs.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/e_generate_scores/
sbatch 12_Job_Categorise_UKB_SNPs.sh
```
This runs `categorise_UKB_SNPs.R` to categorise snps in the data by whether Allele B of UK Biobank (coded to be the effect allele in the previous stage) is the allele which increases risk of insomnia or not.
It uses `LogORlist-aligned-[analysis + number].txt` in the `code/PHESANT-MR-PheWAS-Insomnia/inputs/[analysis + number]/` folder), columns 3 and 6 of `data/[analysis + number]/snps-dosage-[analysis + number].txt` and `data/[analysis + number]/EAF-[analysis + number].txt`. 
It outputs the file `data/[analysis + number]/snpdata-[analysis + number].txt'.
## Calculate Genetic Risk Scores
### Run 13_Job_Generate_Scores.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/e_generate_scores
sbatch 13_Job_Generate_Scores.sh
```
This runs `score_gen.R` to calculate genetic risk scores (standardised and unstandardised) for insomnia for each participant.
This uses the outputs of `10_Job_Exclude.sh` and `12_Job_Categorise_UKB_SNPs.sh`. 
It outputs the files `data/[analysis + number]/scores-[analysis + number].txt`, `data/[analysis + number]/scores-PHESANT-[analysis + number].csv` and `data/[analysis + number]/data-aligned-[analysis + number].txt`.
