# a_make_inputs
## Make Inputs
### Run 1_Job_Make_Inputs_Analysis2.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/a_make_inputs/
sbatch 1_Job_Make_Inputs_Analysis2.sh
```
This uses `code/PHESANT-MR-PheWAS-Insomnia/inputs/analysis2/SNPlist-analysis2.txt` to create `code/PHESANT-MR-PheWAS-Insomnia/inputs/analysis2/LogORlist-analysis2.txt` using the 23andMe Insomnia GWAS summary data.
### Install TwoSampleMR Package
```
#Load and initiate R
module add languages/r/4.0.2
R

#Import Home varible from bash which contains the filepath to my section of BC4
HOME=Sys.getenv("HOME")

#Put filepaths in variables
LIB<-paste(HOME, "/R/x86_64-pc-linux-gnu-library/4.0", sep="")

#Set library and load packages
library(remotes)
remotes::install_github("MRCIEU/TwoSampleMR",  lib=LIB)

q()
```
### Run 2_Job_Make_Inputs_Analysis3.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/a_make_inputs/
sbatch 2_Job_Make_Inputs_Analysis3.sh
```
This runs `clump.R` and creates `code/PHESANT-MR-PheWAS-Insomnia/inputs/analysis3/SNPlist-analysis3.txt`, `code/PHESANT-MR-PheWAS-Insomnia/inputs/analysis3/LogORlist-analysis3.txt` and `code/PHESANT-MR-PheWAS-Insomnia/inputs/exposure_data.txt` (for 2-sample follow-up) using the 23andMe Insomnia GWAS summary data and the clump_data function from the TwoSampleMR package.
