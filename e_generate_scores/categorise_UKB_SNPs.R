#Import HOME variable from bash
HOME=Sys.getenv("HOME")

#Put paths in variable
INPUT=paste(HOME, "/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/inputs", sep="")
DATA=paste(HOME, "/scratch/InsomniaMRPheWAS/data/", sep="")

#Load data.table package
library(data.table)

#Create new function called categorise with 'folder'as input
categorise <- function(folder){

	#Set working directory
	setwd(INPUT)

	#Read LogORlist
	logORlist<-fread(paste(folder, "/LogORlist-aligned-", folder, ".txt", sep=""), header=TRUE, data.table=F)

	#Set working directory to specific analysis folder
	setwd(paste(DATA, folder, sep=""))

	#Read list of snps and effect alleles in UKB data
	snp_summary_stats<-fread(paste("snps-dosage-", folder, ".txt", sep=""), select=c(3, 6), header=FALSE, data.table=F)

	#Read EAF data
	EAFData<-fread(paste("EAF-", folder, ".txt", sep=""), header=FALSE, data.table=F)
	print(nrow(EAFData))

	#Set column names
	names(snp_summary_stats)=c("rsid", "effect_allele")
	names(EAFData)=c("rsid", "EAF")

	#Add rownumber column tp UKB snps so rows can be re-ordered. (print as sanity check)
	rownum  <- 1:nrow(snp_summary_stats)
	snp_summary_stats<-cbind(snp_summary_stats, rownum)
	print(snp_summary_stats)

	#Merge with EAF data (print as sanity check)
	snp_summary_stats<-merge(snp_summary_stats, EAFData, by = "rsid")
	print(nrow(snp_summary_stats))
	print(snp_summary_stats)

	#Return rows to original order (print as sanity check)
	rownum<-snp_summary_stats$rownum
	snp_summary_stats <- snp_summary_stats[order(rownum),]
	print(snp_summary_stats)

	#Create vector called direction which is the length of snps
	direction<-vector(length = length(snp_summary_stats$rsid))

	#Loop through snps in the UKB data and find correcsponding snps in the LogORlist using index.
	#If the UKB effect allele matches neither of the alleles in the LogORlist (not for palindromic snps) then flip the reference strand.  
	#Then mark (non-palindromic)snps as in the same direction or not in the direction vector if the effect alleles match or not
	#And then mark the direction of palindromic snps by EAF
	for (i in 1:length(snp_summary_stats$rsid)){ 
		index<-which(logORlist$rsid==snp_summary_stats$rsid[i])
		print(index)
		print(snp_summary_stats[i, ])
		print(logORlist[index, ])
		if ((snp_summary_stats$effect_allele[i]!=logORlist$effect_allele[index]) & (snp_summary_stats$effect_allele[i]!=logORlist$other_allele[index]) & (logORlist$pal[index]==0)){
                       if (snp_summary_stats$effect_allele[i]=="A") {
                              snp_summary_stats$effect_allele[i]<-"T"
                        } else if (snp_summary_stats$effect_allele[i]=="T") {
                                snp_summary_stats$effect_allele[i]<-"A"
                        } else if (snp_summary_stats$effect_allele[i]=="C") {
                                snp_summary_stats$effect_allele[i]<-"G"
                        } else if (snp_summary_stats$effect_allele[i]=="G") {
                                snp_summary_stats$effect_allele[i]<-"C"
                        } 
		} 
		if((snp_summary_stats$effect_allele[i]==logORlist$effect_allele[index]) & (logORlist$pal[index]==0)){
			direction[i]<-2
		} else if ((snp_summary_stats$effect_allele[i]==logORlist$other_allele[index]) & (logORlist$pal[index]==0)){
			direction[i] <-1
		} else if (logORlist$pal[index]==1){
			if (((logORlist$EAF[index]<0.49) & (snp_summary_stats$EAF[i]<0.49)) | ((logORlist$EAF[index]>0.51) & (snp_summary_stats$EAF[i]>0.51))){
				direction[i]<-2
			} else if (((logORlist$EAF[index]<0.49) & (snp_summary_stats$EAF[i]>0.51)) | ((logORlist$EAF[index]>0.51) & (snp_summary_stats$EAF[i]<0.49))){
				direction[i]<-1
                        } else {
				direction[i]<-0
			}   
		}
	}

	#Update names in LogORlist to avoid duplicate column names when merged with the UKB snps
	names(logORlist)=c("rsid", "effect_allele_GWAS", "other_allele_GWAS", "logOR_GWAS", "EAF_GWAS", "pal")

	#Bind UKB snps with the direction vector (print as sanity check)
	snp_summary_stats<-cbind(snp_summary_stats, direction)
	print(snp_summary_stats)

	#Merge LogORlist with UKB snp info (and sanity check)
	complete_snp_summary_stats <- merge(snp_summary_stats, logORlist, by="rsid")
	print(complete_snp_summary_stats)
	print(nrow(complete_snp_summary_stats))

	#Use row number to reorder
	completerownum<-complete_snp_summary_stats$rownum
	complete_snp_summary_stats <- complete_snp_summary_stats[order(completerownum),]
	print(complete_snp_summary_stats)

	#Save table
	write.table(complete_snp_summary_stats, paste("snp-summary-stats-", folder, ".txt", sep=""), row.names=FALSE, sep = " ", quote=FALSE)
}


#Run for analysis 1
folder<-"analysis1"
categorise(folder)

#Run for analysis 2
folder<-"analysis2"
categorise(folder)

#Run for analysis 3
folder<-"analysis3"
categorise(folder)


