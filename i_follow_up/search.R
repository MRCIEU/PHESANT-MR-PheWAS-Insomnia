#Import HOME variable from bash
HOME=Sys.getenv("HOME")

#Put filepaths in variables
OUTPUT=paste(HOME, "/scratch/InsomniaMRPheWAS/output/", sep="")
INPUT=paste(HOME, "/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/inputs", sep="")
LIB<-paste(HOME, "/R/x86_64-pc-linux-gnu-library/4.0", sep="")

#Load packages
.libpaths=LIB
library(data.table, lib=LIB)
library(TwoSampleMR, lib=LIB)

#############
# LOAD DATA #
#############

setwd(INPUT)
searchterms<-fread("searchterms.txt", header=FALSE, data.table=F)

##########
# SEARCH #
##########

#Create dataframes
ao <- available_outcomes()
hits <- ao
hits <- hits[0,]
gwas<- ao
gwas <- gwas[0,]

#Do search
for (i in 1:nrow(searchterms)){
	if (!is.na(searchterms[i,2])){

		#Clear hits
    		hits <- hits[0,]

		#Split up search terms for outcome into list
		terms<-as.list(strsplit(searchterms[i,2], ", ")[[1]])
		
		#Seach for each and compile into table
		for (j in 1:length(terms)){
			temp<-subset(ao, grepl(terms[j], trait, ignore.case=TRUE))
                        hits<-rbind(hits, temp)
		}

		#De-duplicate, remove UK Biobank, remove non-european, remove sex stratified (also remove eqtl GWAS which were added after analysis was completed but before the paper published)
		hits<-unique(hits)
		hits<-hits[!grepl("ukb-", hits$id),]
		hits<-hits[!grepl("ubm-", hits$id),]
		hits<-hits[!grepl("met-d-", hits$id),]
		hits<-hits[!grepl("eqtl-", hits$id),]
		hits<-hits[!grepl("UKBiobank", hits$note),]
                hits<-hits[!grepl("UK Biobank", hits$consortium),]
		hits<-hits[!grepl("bbj-", hits$id),]
		hits<-hits[!grepl("East Asian", hits$population),]
                hits<-hits[!grepl("Mixed", hits$population),]
                hits<-hits[!grepl("Hispanic or Latin American", hits$population),]
                hits<-hits[!grepl("African American or Afro-Caribbean", hits$population),]
                hits<-hits[!grepl("Sub-Saharan African", hits$population),]
                hits<-hits[!grepl("South Asian", hits$population),]
    		hits<-hits[grepl("Males and Females|NA", hits$sex),]

		#Add to table
		gwas<-rbind(gwas, hits)

	} else {
	}
}

#Remove duplicates
gwasuniq<-unique(gwas)

#############
# SAVE DATA #
#############

setwd(OUTPUT)
write.table(gwasuniq, "gwaslist.txt", row.names=FALSE, sep = "\t", quote=FALSE)

