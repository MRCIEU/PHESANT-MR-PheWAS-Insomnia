#Import HOME variable from bash
HOME=Sys.getenv("HOME")

#Put filepaths in variables
OUTPUT=paste(HOME, "/scratch/InsomniaMRPheWAS/output/", sep="")
INPUT=paste(HOME, "/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/inputs", sep="")

#Load packages
library(data.table)
library(ggplot2)
library(scales)

#############
# LOAD DATA #
#############

#Load data
setwd(OUTPUT)
data<-fread("PHESANT-processed.txt", header=TRUE, data.table=F)

#Load and name headers in category files
setwd(INPUT)
categories<-fread("categories.txt", header=FALSE, data.table=F)
names(categories)<-c("Category", "Path")
override<-fread("categories_override.txt", header=FALSE, data.table=F, sep="\t")
names(override)<-c("Field_ID", "Category")

##################
# ADD CATEGORIES #
##################

#Add in Categories
data$Category<-"No-Cat"

for (i in 1:nrow(categories)){
	path<-categories$Path[i]
	category<-categories$Category[i]
	for (j in 1:nrow(data)){
		if (data$Path[j]==path){
			data$Category[j]<-category
		}
	}
}

#Check everything has been categorised
print(nrow(subset(data, Category=="No-Cat")))

#Fill subcategory column with "No-Subcat"
data$Subcategory<-"No-Subcat"

############
# OVERRIDE #
############

for (i in 1:nrow(override)){
        j<-which(data$Field_ID==override$Field_ID[i])
        data$Category[j]<-override$Category[i]
}


############################################
#  PRODUCE TABLES FOR CATEGORY BARCHART    #
############################################

#Get number of outcomes sig in main analysis
datasig<-subset(data, Sig=="+++" | Sig=="++-" | Sig=="+-+" |Sig=="+--")
sigresults<-nrow(datasig)

#Make vectors for coming loop
sig<-vector()
percent<-vector()
total<-vector()
categorylist<-unique(data$Category)

#Get number of sig results, nonsig results, percentages and total outcomes for each category
for (i in 1:length(categorylist)){
	category<-categorylist[i]
	subsetdata<-subset(data, Category==category)
	total[i]<-(nrow(subsetdata))
	subsetdata<-subset(datasig, Category==category)
	sig[i]<-(nrow(subsetdata))
	percent[i]<-(sig[i]/total[i])*100
	categorylist[i]<-paste(categorylist[i], " (n=",  total[i], ")", sep="")
}

#Create table of info and name columns 
charttable<-data.frame(categorylist, sig, total, percent)
names(charttable)<-c("Category", "Sig", "Total", "Percent")
charttable$Category <- factor(charttable$Category, levels=sort(unique(charttable$Category), decreasing = TRUE))

#####################
# CREATE BAR CHART  #
#####################

#Set working directory
setwd(OUTPUT)

#Make category barchart, order by percent, set text to size 15 and flip axis.
p <- ggplot(charttable, aes(x = reorder(Category, -Percent), y = Percent))+
        geom_bar(stat="identity", fill="steelblue")+
	xlab("Category")+     
	theme_minimal()+
	theme(text = element_text(size=15))+
	coord_flip()
ggsave("categorybarchart.jpg", p)

#############
# SAVE DATA #
#############

write.table(data, "PHESANT-categories.txt", row.names=FALSE, sep = "\t", quote=FALSE)
write.table(charttable, "category-charttable.txt", row.names=FALSE, sep = "\t", quote=FALSE)
