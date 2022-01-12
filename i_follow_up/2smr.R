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
library(ggplot2)

#############
# LOAD DATA #
#############

#Load data
setwd(INPUT)
gwas<-fread("mrbaseids.txt", header=FALSE, data.table=F)
cont<-fread("contFUoutcomes.txt", header=TRUE, data.table=F, sep="\t")
exposure_snps <- read_exposure_data("exposure_data.txt", sep="\t")

######
# MR #
######

#Create data frames
results<-data.frame(outcome=c(), methods=c(), nsnps=c(), b=c(), se=c(), pval=c())
pleiotropy<-data.frame()
heterogeneity<-data.frame()

#Run MR
for (i in 1:nrow(gwas)){

	#process Data
	out_data<-extract_outcome_data(exposure_snps$SNP, gwas[i, 1], proxies=TRUE)
	dat <- harmonise_data(exposure_snps, out_data, action = 2)

	#MR
	mr_results <- mr(dat, method_list=c("mr_ivw","mr_egger_regression","mr_weighted_median"))
	temp_results<-mr_results[,c(3,5,6,7,8,9)]
	results<-rbind(results, temp_results)

	#Pleitropy
	temp_pleiotropy<-mr_pleiotropy_test(dat)[,c(3,5,6,7)]
	names(temp_pleiotropy)<-c("outcome", "mr_egger_intercept", "intercept_se", "intercept_pval")
	temp_pleiotropy$method<-"MR Egger"
	pleiotropy<-rbind(pleiotropy, temp_pleiotropy)

	#Heterogeneity
	temp_heterogeneity<-mr_heterogeneity(dat)[,c(3,5,6,7,8)]
        heterogeneity<-rbind(heterogeneity, temp_heterogeneity)
}

#combine
combined_results<-merge(results, pleiotropy, by=c("outcome","method"), all.x = TRUE)
combined_results<-merge(combined_results, heterogeneity, by=c("outcome","method"), all.x = TRUE)

#########
# 95%CI #
#########

combined_results$lower<- combined_results$b - (1.96*combined_results$se)
combined_results$upper<- combined_results$b + (1.96*combined_results$se)


########################
# CHANGE OUTCOME NAMES #
########################

for (i in 1:nrow(combined_results)){
  combined_results$outcome[i]<-unlist(strsplit(combined_results$outcome[i], split=' ||', fixed=TRUE))[1]
}

###################
# SPLIT OR and MD #
###################

combined_resultsOR<- subset(combined_results, !(outcome %in% cont$outcome))
combined_resultsMD<- subset(combined_results, outcome %in% cont$outcome)

################
# CHANGE TO OR #
################

combined_resultsOR$b<-exp(combined_resultsOR$b)
combined_resultsOR$lower<-exp(combined_resultsOR$lower)
combined_resultsOR$upper<-exp(combined_resultsOR$upper)
combined_resultsOR$mr_egger_intercept<-exp(combined_resultsOR$mr_egger_intercept)

#############
# SAVE DATA #
#############

setwd(OUTPUT)
write.table(combined_resultsOR, "FU-Full-OR.txt", row.names=FALSE, sep = "\t", quote=FALSE)
write.table(combined_resultsMD, "FU-Full-MD.txt", row.names=FALSE, sep = "\t", quote=FALSE)
