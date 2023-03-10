#Import HOME variable from bash
HOME=Sys.getenv("HOME")

#Put filepaths in variables
DATA=paste(HOME, "/scratch/InsomniaMRPheWAS/data/", sep="")

#Load packages
library(data.table)

#############
# LOAD DATA #
#############

setwd(DATA)
data<-fread("analysis1/data-excld-analysis1.txt", select=c(2), header=TRUE, data.table=F)
baseline<-fread("baseline.txt", header=TRUE, data.table=F)

data<-merge(data, baseline)

#####################
# GET DESCRITPTIVES #
#####################

for (i in 2: length(data)){
	print(names(data)[i])
	if (names(data)[i]=="Age" | names(data)[i]=="Townsend"){
		print(summary(data[,i]))
		print(sd(data[,i], na.rm=TRUE))
	} else {
		x<-print(table(data[,i], useNA="always"))
		print(x/sum(x)*100)
	}
}
