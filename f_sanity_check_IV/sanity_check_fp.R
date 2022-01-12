#Import HOME variable from bash
HOME=Sys.getenv("HOME")

#Put paths in variables and set working directory
OUTPUT=paste(HOME, "/scratch/InsomniaMRPheWAS/output", sep="")

#Load packages
library(data.table)
library(ggplot2)

#Create function called sanity_check_fp with 'folder' as input
sanity_check_fp <- function(folder) {

	#set working directory
	setwd(OUTPUT)

	#Read data
	forestdata<-fread(paste(folder, "/sancheck/forestplottable-", folder, ".txt", sep=""), header=TRUE, data.table=F)

	forestdata<-forestdata[order(forestdata$or),]
	forestdata$snp<-factor(forestdata$snp, levels=forestdata$snp)

	#Create forestplot
	forest <- ggplot(data=forestdata, aes(x=snp, y=or, ymin=lower, ymax=upper)) +
        	geom_pointrange() + 
        	geom_hline(yintercept=1, lty=2) +  # add a dotted line at x=1 after flip
        	coord_flip() +  # flip coordinates (puts labels on y axis)
        	xlab("SNP") + ylab("Odds Ratio (95% CI)") + #add axis labels
        	theme(axis.text.y=element_text(size=3.5))  # use a white background and text of size 2 for y axis (After flip)

	#Set working directory and Save
	setwd(OUTPUT)
	ggsave(paste(folder, "/sancheck/graphs/forest-plot-", folder, ".jpg", sep=""), forest)
}

#Run for analyses 1 and 3 (1 is identical SNPs to 2)
folder<-"analysis1"
sanity_check_fp(folder)
folder<-"analysis3"
sanity_check_fp(folder)

