# f_sanity_check_IV
## Extract Insomnia Data
### Input the following code directly into the command line
```
#Put paths in variables
PHEN_DATA="$APP_16729/2021-02-24/data/"
DATA="${HOME}/scratch/InsomniaMRPheWAS/data/"
PC="$UK_B_LATEST/data/derived/principal_components"

#Get column number for Age (8817), Sex (11) and Insomnia (841)
head -n1 $PHEN_DATA/data.43017.phesant.tab | sed 's/\t/\n/g' | nl | grep -n "x21022_0_0"
head -n1 $PHEN_DATA/data.43017.phesant.tab | sed 's/\t/\n/g' | nl | grep -n "x31_0_0"
head -n1 $PHEN_DATA/data.43017.phesant.tab | sed 's/\t/\n/g' | nl | grep -n "x1200_0_0"

#Extract columns and IDs from data
cut -f1,8817,11,841 $PHEN_DATA/data.43017.phesant.tab > $DATA/insomnia.txt

#Take first 10 Principal Components
cp $PC/data.pca1-10.qctools.txt $DATA/PC.txt
```
This extracts the phenotype IDs, age, sex and insomnia at baseline data from the UK Biobank phenotype data (`$APP_16729/data/data.43017.phesant.tab`).
It also extracts the top 10 principal components from the UK Biobank genetic data (`UK_B_LATEST/data/derived/principal_components/data.pca1-10.qctools.txt`).
## Sanity Check Distribution and Prediction of Scores
### Run 14_Job_Sanity_Check_Scores.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/f_sanity_check_IV/
sbatch 14_Job_Sanity_Check_Scores.sh
```
This runs `sanity_check_scores.R` which produces histograms of the standardised genetic risk scores, runs a logistic regression between scores and insomnia and calculates the correlations between the three scores. 
This uses `data/[analysis + number]/scores-[analysis + number].txt`, `data/PC.txt` and `data/insomnia.txt`.
It outputs the files:
```
output/[analysis + number]/sancheck/graphs/histogram-[analysis + number].jpg
output/[analysis + number]/sancheck/regression-[analysis + number].txt
output/score-correlations.txt
data/insomnia-processed.txt
data/confounders.csv
```
## Create Forest Plots
### Run 15_Job_Sanity_Check_Dosages.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/f_sanity_check_IV/
sbatch 15_Job_Sanity_Check_Dosages.sh
```
This runs sanity_check_dosages.R which processes the Insomnia data to be binary and creates a forest plot for each snp regressed with Insomnia.
This uses `data/insomnia-processed.txt`, `data/[analysis + number]/data-aligned-[analysis + number].txt`.
It outputs (for analyses 1 and 3 and 1 is identical to 2):
```
output/[analysis + number]/sancheck/forestplottable-[analysis + number].txt
output/[analysis + number]/sancheck/graphs/forestplot-[analysis + number].jpg
```
