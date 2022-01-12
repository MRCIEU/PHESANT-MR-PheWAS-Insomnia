HOME=Sys.getenv("HOME")

#Put paths in variables and set working directory
DATA=paste(HOME, "/scratch/InsomniaMRPheWAS/data", sep="")
OUTPUT=paste(HOME, "/scratch/InsomniaMRPheWAS/output", sep="")

#Load packages
library(data.table)
library(ggplot2)

#Read insomnia data (502536 rows)
setwd(DATA)
insom<-fread("insomnia-processed.txt", header=TRUE, data.table=F)
print(nrow(insom))
head(insom)

#Create function called sanity_check_dosage with 'folder' as input
sanity_check_dosage <- function(folder) {

	#Set working directory
	setwd(DATA)

	#######################
	# READ AND MERGE DATA #
	#######################

	#Read aligned UKB data
	datasnps<-fread(paste(folder, "/data-aligned-", folder, ".txt", sep=""), header=TRUE, data.table=F)

	#Merge with insomnia (336766 rows)
	data <- merge(insom, datasnps, by="eid")
	print(nrow(data))

	#######################
	# CONDUCT REGRESSIONS #
	#######################

	#Create vectors needed for loop
	snp <- vector()
	cf <- vector()
	lowercoint <- vector()
	uppercoint <- vector()
	pvalue <- vector()

	#Get number of snp columns
	a<-length(datasnps[1,])

	#Loop through SNP columns and regress each with Insomnia controlling for age sex and PCs. Then extract results and place in the previously made vectors
	for (i in 3:a){
		snp[i]<-colnames(datasnps[i])
		snpnow<-colnames(datasnps[i])
		logit <- glm(insomnia ~ get(snpnow) + age + sex  + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10, data=data, family = "binomial")
		cf[i] <- coef(logit)["get(snpnow)"]
		cis<-confint(logit, "get(snpnow)", level=0.95)
		lowercoint[i] <- cis["2.5 %"]
		uppercoint[i] <- cis["97.5 %"]
		sumfor <- summary(logit)
		sumfor <- sumfor$coefficients
		ps <- sumfor[,"Pr(>|z|)"]
		pvalue[i] <- ps["get(snpnow)"]
	}
	
	#Bind vectors into table
	forestdata <- data.frame(snp, cf, lowercoint, uppercoint, pvalue)

	#Remove first two empty rows
	forestdata <- forestdata[-c(1,2),]

	##########################
	# CONVERT TO ODDS RATIOS #
	##########################

	#Convert to odds ratio
	forestdata$or<-exp(forestdata$cf)
	forestdata$lower<-exp(forestdata$lowercoint)
	forestdata$upper<-exp(forestdata$uppercoint)
	
	#######################
	# SORT BY EFFECT SIZE #
	#######################

	forestdata<-forestdata[order(forestdata$or),]
	forestdata$snp<-factor(forestdata$snp, levels=forestdata$snp)

	######################
	# CREATE FOREST PLOT #
	######################

	#Add dotted line at 1 of the y axis, set axis labels, flip the axis, then set text size to 2 for y axis
	forest <- ggplot(data=forestdata, aes(x=snp, y=or, ymin=lower, ymax=upper)) +
		geom_pointrange() + 
		geom_hline(yintercept=1, lty=2) +
		xlab("SNP") + ylab("Odds Ratio (95% CI)") +
		coord_flip() +
		theme(axis.text.y=element_text(size=2))

	#############
	# SAVE DATA #
	#############

	setwd(OUTPUT)
	ggsave(paste(folder, "/sancheck/graphs/forest-plot-", folder, ".jpg", sep=""), width = 6, height = 6, forest)
	write.table(forestdata, paste(folder, "/sancheck/forestplottable-", folder, ".txt", sep=""), row.names=FALSE, sep = " ", quote=FALSE)
}

#Run for analyses 1 and 3 (2 is identical to 1)
folder<-"analysis1"
sanity_check_dosage(folder)
folder<-"analysis3"
sanity_check_dosage(folder)
