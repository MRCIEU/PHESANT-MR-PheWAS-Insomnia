# j_Baseline
## Get descriptive statistics for population characteristics.
### Run 30_Job_Baseline.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/j_baseline
sbatch 30_Baseline.sh
```
This runs the R script `baseline.R` which takes `code/PHESANT-MR-PheWAS-Insomnia/data/analysis1/data-excld-analysis1.txt` file and calculates descriptives and prints these to the log file.
