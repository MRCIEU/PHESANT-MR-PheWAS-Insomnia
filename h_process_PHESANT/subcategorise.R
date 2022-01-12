#Import HOME variable from bash
HOME=Sys.getenv("HOME")

#Put filepaths in variables
OUTPUT=paste(HOME, "/scratch/InsomniaMRPheWAS/output/", sep="")
INPUT=paste(HOME, "/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/inputs", sep="")

#Load packages
library(data.table)
library(ggplot2)
library(scales)

#Load data
setwd(OUTPUT)
data<-fread("PHESANT-categories.txt", header=TRUE, data.table=F)

#Create function called subcategorise with inputs 'category' and name
subcategorise <- function(category, name){

	#Load and name headers in subcategory file
	setwd(INPUT)
	subcategories<-fread(paste("subcategories_", category, ".txt", sep=""), header=FALSE, data.table=F, sep="\t")
	names(subcategories)<-c("Field_ID", "Subcategory")

	################################
	# ADD SUBCATEGORIES CATEGORIES #
	################################

	#Add Subcategories
	for (i in 1:nrow(subcategories)){
		j<-which(data$Field_ID==subcategories$Field_ID[i])
        	data$Subcategory[j]<<-subcategories$Subcategory[i]
	}

	############################################
	#  PRODUCE TABLES FOR CATEGORY BARCHARTS   #
	############################################

	#Get number of outcomes sig in main analysis
	datasig<-subset(data, Sig=="+++" | Sig=="++-" | Sig=="+-+" |Sig=="+--")
	sigresults<-nrow(datasig)

	#Make vectors for coming loop
	sig<-vector()
	percent<-vector()
	total<-vector()
	
	#Get subcategorylist
	catdata<<-subset(data, Category==name)
	subcategorylist<-unique(catdata$Subcategory)

	#Get number of sig results, nonsig results, percentages and total outcomes for each subcategory
	for (i in 1:length(subcategorylist)){
	        subcategory<-subcategorylist[i]
	        subsetdata<-subset(data, Subcategory==subcategory)
	        total[i]<-(nrow(subsetdata))
	        subsetdata<-subset(datasig, Subcategory==subcategory)
	        sig[i]<-(nrow(subsetdata))
	        percent[i]<-(sig[i]/total[i])*100
	        subcategorylist[i]<-paste(subcategorylist[i], " (n=",  total[i], ")", sep="")
	}

	#Create table of info and name columns
	charttable<-data.frame(subcategorylist, sig, total, percent)
	names(charttable)<-c("Subcategory", "Sig", "Total", "Percent")
	charttable$Subcategory <- factor(charttable$Subcategory, levels=sort(unique(charttable$Subcategory), decreasing = TRUE))

	#####################
	# CREATE BAR CHARTS #
	#####################
	
	#Set working directory
	setwd(OUTPUT)

	#Make subcategory barchart, order by percent, set text to size 15, and flip axis
	p <- ggplot(charttable, aes(x = reorder(Subcategory, -Percent), y = Percent))+
        	geom_bar(stat="identity", fill="steelblue")+
        	xlab("Subcategory")+	
		theme_minimal()+
		theme(text = element_text(size=15))+
        	coord_flip()
	ggsave(paste(category, "-barchart.jpg", sep=""), p)

	#############
	# SAVE DATA #
	#############

	write.table(charttable, paste(category, "-charttable.txt", sep=""), row.names=FALSE, sep = "\t", quote=FALSE)
}


#Run for Mental Health
category<-"mentalhealth"
name<-"Mental Health"
subcategorise(category, name)

#Check everything has been categorised
print(nrow(catdata))
print(nrow(subset(catdata, Subcategory=="No-Subcat")))

#Run for Physical Health
category<-"physicalhealth"
name<-"Physical Health"
subcategorise(category, name)

#Check everything has been categorised
print(nrow(catdata))
print(nrow(subset(catdata, Subcategory=="No-Subcat")))

#Save data
write.table(data, "PHESANT-subcategories.txt", row.names=FALSE, sep = "\t", quote=FALSE)

