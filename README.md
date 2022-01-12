# An MR-PheWAS of insomnia using PHESANT
The following pipeline conducts a MR-PheWAS for Insomnia in UK Biobank via three methods (analysis 1-3). The first uses GWAS significant snps identified in a meta analysis of UK Biobank and 23andme (which were also significant in just the 23andMe cohort) to create wieghted genetic risk scores using the ORs from the meta analysis. The second uses the same SNPs but the ORs from the 23andMe cohort. The third uses all SNPs significant in the 23andMe cohort with the ORs from this cohort. The third of these is the main analysis and the others are sensitivity analysis. The analyses are numbered in the order they were conducted in due to the order the data and resources needed for each were accessed.

## Directory Structure
### The project folder has the following structure:
```
InsomniaMRPheWAS/code
InsomniaMRPheWAS/data
InsomniaMRPheWAS/output
```
### The code directory has the following structure:
```
code/PHESANT-MR-PheWAS-Insomnia/a_make_inputs
code/PHESANT-MR-PheWAS-Insomnia/b_retrieve_data
code/PHESANT-MR-PheWAS-Insomnia/c_reformat_data
code/PHESANT-MR-PheWAS-Insomnia/d_exclusions
code/PHESANT-MR-PheWAS-Insomnia/e_generate_scores
code/PHESANT-MR-PheWAS-Insomnia/f_sanity_check_IV
code/PHESANT-MR-PheWAS-Insomnia/g_PHESANT_analysis/analysis1
code/PHESANT-MR-PheWAS-Insomnia/g_PHESANT_analysis/analysis2
code/PHESANT-MR-PheWAS-Insomnia/g_PHESANT_analysis/analysis3
code/PHESANT-MR-PheWAS-Insomnia/h_process_PHESANT
code/PHESANT-MR-PheWAS-Insomnia/i_follow_up
code/PHESANT-MR-PheWAS-Insomnia/inputs/analysis1
code/PHESANT-MR-PheWAS-Insomnia/inputs/analysis2
code/PHESANT-MR-PheWAS-Insomnia/inputs/analysis3
```
### The data directory has the following structure:
```
data/analysis1/snps_by_chrom
data/analysis2/snps_by_chrom
data/analysis3/snps_by_chrom
data/snp_stats
```
### The output directory has the following structure:
```
output/analysis1/sancheck/graphs
output/analysis1/PHESANT
output/analysis2/sancheck/graphs
output/analysis2/PHESANT
output/analysis3/sancheck/graphs
output/analysis3/PHESANT
```

## Input Files
```
code/PHESANT-MR-PheWAS-Insomnia/inputs/analysis1/SNPlist-analysis1.txt
code/PHESANT-MR-PheWAS-Insomnia/inputs/analysis2/SNPlist-analysis2.txt
```
Each of these lists the snps to be extracted in one column with no header (They are identical). They are created from supplemetary table 6 from Jansen et al. `code/inputs/analysis2/SNPlist-analysis3.txt` is created by `code/PHESANT-MR-PheWAS-Insomnia/scripts/a_make_inputs/2_Job_Make_Inputs_Analysis3.sh' which uses 23andMe Insomnia GWAS summary data.
```
code/PHESANT-MR-PheWAS-Insomnia/inputs/analysis1/LogORlist-analysis1.txt
```
This contains five columns (SNP rsID, Allele 1, Allele 2, LogOdds Ratio and Allele 1 Frequency) with the headers rsID, A1, A2, LogOR, EAF. It is created from supplementay table 6 from Jansen et al. `code/inputs/analysis2/LogORlist-analysis2.txt` and `code/inputs/analysis3/LogORlist-analysis3.txt are created by  created by `code/PHESANT-MR-PheWAS-Insomnia/scripts/a_make_inputs/1_Job_Make_Inputs_Analysis2.sh' and `code/PHESANT-MR-PheWAS-Insomnia/scripts/a_make_inputs/2_Job_Make_Inputs_Analysis3.sh' respectively which use 23andMe Insomnia GWAS summary data.
```
code/PHESANT-MR-PheWAS-Insomnia/inputs/categories.txt
code/PHESANT-MR-PheWAS-Insomnia/inputs/subcategories_mentalhealth.txt
code/PHESANT-MR-PheWAS-Insomnia/inputs/subcategories_physicalhealth.txt
```
These files stipulate which UKB paths are assigned to which categories and which UKB IDs are assigned to which subcatergories.
```
code/PHESANT-MR-PheWAS-Insomnia/inputs/searchterms.txt
```
This file contains the search terms used to search MRBase for follow-up GWAS (created after the PheWAS).
```
code/PHESANT-MR-PheWAS-Insomnia/inputs/mrbaseids.txt
```
This file contains the list of MRBase IDs for follow up (created after the search).
```
code/PHESANT-MR-PheWAS-Insomnia/inputs/contFUoutcomes.txt
```
This file contains the list of MRBase IDs for continuous outcomes so they can be split from binary outcomes and visualised seperately with a mean difference rather than odds ratio.
```
code/PHESANT-MR-PheWAS-Insomnia/inputs/FUcats.txt
```
This file contains information to format the final forest plots (such as groupings effect estimate type).
All Input, data and output files specific to an anlysis will be created with a name ending "-analysis1.", "-analysis2." or "-analysis3.".
