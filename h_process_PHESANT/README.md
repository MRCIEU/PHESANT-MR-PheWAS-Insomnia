# h_process_PHESANT
## Combine PHESANT Analyses Outputs
### Run 25_Job_process_PHESANT.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/h_process_PHESANT
sbatch 25_Job_Process_PHESANT.sh
```
This runs the R script `process_PHESANT.R` which takes the `output/[analysis + number]/PHESANT/results-combined.txt` file for each analysis, combines the relevant columns and makes two new colums coding the direction of associations for each varibale in each analysis and whether each varibale is under the Bonferroni corrected threshold for each analysis.
It outputs the files `output/PHEASANT-processed.txt` and `output/VenDiagramTable.txt`.
## Categorise Outcomes
### Run 26_Job_Categorise.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/h_process_PHESANT
sbatch 26_Job_Categorise.sh
```
This runs the R script `categorise.R` which takes the `output/PHESANT--processed.txt` file and uses the `categories.txt` and `categories_override.txt` from the `code/PHESANT-MR-PheWAS-Insomnia/inputs` folder to add in a category column and creates a table and barchart of numbers and percents of each category. 
It also adds and unfilled subcategory column. 
It outputs the files: 
```
output/PHEASANT-categories.txt
output/category-charttable.txt
output/categorybarchart.jpg
```
It then runs the R script `subcategorise.R` which adds in a category column and creates a table and barchart of the numbers and percents of each subcategory within the two categories.
It uses:
```
output/PHEASANT-categories.txt
code/PHESANT-MR-PheWAS-Insomnia/inputs/subcategories_mentalhealth.txt
code/PHESANT-MR-PheWAS-Insomnia/inputs/subcategories_physicalhealth.txt
```
It ouptputs:
```
output/PHEASANT-subcategories.txt
output/mentalhealth-charttable.txt
output/mentalhealth-barchart.jpg
output/physicalhealth-charttable.txt
output/physicalhealth-categorybarchart.jpg
``` 
