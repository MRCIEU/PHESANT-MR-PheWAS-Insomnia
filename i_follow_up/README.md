# i_follow_up
## Search MRBase
### Run 27_Job_Search_MRBase.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/i_follow_up
sbatch 27_Job_Search_MRBase.sh
```
This runs the R script `search.R` which takes the `code/PHESANT-MR-PheWAS-Insomnia/inputs/searchterms.txt` file and searches MRBase using the TwoSampleMR package.
It outputs the file `output/gwaslist.txt`. This is then screened manually and the file `code/PHESANT-MR-PheWAS-Insomnia/inputs/mrbaseids.txt` is created.
## Conduct 2SMR Follow-Up
### Run 28_Job_2SMR.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/i_follow_up
sbatch 28_Job_2SMR.sh
```
This runs the R script `2smr.R` which takes the `code/PHESANT-MR-PheWAS-Insomnia/inputs/mrbaseids.txt` file to run the follow-up MR for each outcome. 
It outputs full results split by outcome type (continuous or binary) and the same for IVW results: 
```
output/FU-Full-OR.txt
output/FU-Full-MD.txt
```
## Create Forest Plot
### Run 29_Job_Forest_Plot.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/i_follow_up
sbatch 29_Job_Forest_Plot.sh
```
This runs the R script `forest_plot.R` which makes two forest plots.
It's inputs are:
```
output/FU-Full-OR.txt
output/FU-Full-MD.txt
code/PHESANT-MR-PheWAS-Insomnia/inputs/FUcats.txt
```
It outputs:
```
output/FP_OR.jpg
output/FP_MD.jpg
```

