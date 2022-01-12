# d_exclusions
## Extract IDs to be Excluded
### Input the following code directly into the command line
```
#Put paths in variables
RELATED="$UK_B_LATEST/data/derived/related/relateds_exclusions"
ANCESTRY="$UK_B_LATEST/data/derived/ancestry"
DATA="${HOME}/scratch/InsomniaMRPheWAS/data"

#Copy list of white-British IDs
cp $ANCESTRY/data.white_british.qctools.txt $DATA/WB.txt

#Copy list of related IDs
awk '{print $2}' $RELATED/data.minimal_relateds.plink.txt > $DATA/related.txt
```
This gets the list of gen IDs for the White-British (`$UK_B_LATEST/data/derived/ancestry/data.white_british.qctools.txt`)and related (`$UK_B_LATEST/data/derived/related/relateds_exclusions/data.minimal_relateds.plink.txt`) individuals.
## Exclude
### Run 10_Job_Exclude.sh
```
cd $HOME/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/d_exclusions/
sbatch 10_Job_Exclude.sh
```
This runs `exclude.R` which excludes individuals who are not white-British, are minimaly related or have withdrawn their data.
This uses `data/[analysis + number]/data-IDs-[analysis + number].txt`, `data/WB.txt`, `data/related.txt` and `data/withdrawn.txt`.
It ouptuts `data/[analysis + number]/data-excld-[analysis + number].txt` (no analysis2 as identical to analysis1).
The Job script then copies the output for analysis1 for analysis2.
