# g_PHESANT_analysis
## Create Outcome File
### Input the following code directly into the command line
```
#Put paths in variables
PHEN_DATA="$APP_16729/2020-08-12/data"
DATA="${HOME}/scratch/InsomniaMRPheWAS/data/"

#Copy Phenotype data
cp $PHEN_DATA/data.43017.phesant.tab $DATA/data.43017.phesant.tab
```
This copies the correctly formatted phenotype data to the data folder.
## Run PHESANT Analysis
### Run 16_Job_PHESANT_An1_P1.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/g_PHESANT_analysis/analysis1
sbatch 16_Job_PHESANT_An1_P1.sh
```
### Run 17_Job_PHESANT_An1_P2.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/g_PHESANT_analysis/analysis1
sbatch 17_Job_PHESANT_An1_P2.sh
```
These scripts run the PHESANT analysis for Analysis1 in two parts (each part splits it into 100 sub-parts which run in parallel.
This uses `data/analysis1/scores-PHESANT-analysis1.csv`, `data/confounders.csv` and `data.29244.phesant.tab`.
It runs `phenomeScan.r` using `outcome-info.tsv` and `data-coding-ordinal-info.txt`.
All three of these files are from the `PHESANT` folder adjacent to this project folder which was cloned from github. 
The standard outputs can be seen on the PHESANT github page and are saved to `output/analysis1/PHESANT`.
### Run 18_Job_PHESANT_An1_P3.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/g_PHESANT_analysis/analysis1
sbatch 18_Job_PHESANT_An1_P3.sh
```
This uses the output of the previous two stages and the code/inputs/`outcome-info.tsv` file to produce a combined results file and plots.
It outputs:
```
output/analysis1/PHESANT/results-combined.txt
output/analysis1/PHESANT/qqplot.pdf
output/analysis1/PHESANT/variable-flow-counts-combined.txt
output/analysis1/PHESANT/forest-binary.pdf
output/analysis1/PHESANT/forest-continuous.pdf
output/analysis1/PHESANT/forest-ordered-logistic.pdf
```
##Rerun PHESANT for analysis 2and 3.
Jobs 19-24 repeat the prevous three steps for analyses 2 and 3.
