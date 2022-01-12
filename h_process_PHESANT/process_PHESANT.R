#Import HOME variable from bash
HOME=Sys.getenv("HOME")

#Put filepath in variable
OUTPUT=paste(HOME, "/scratch/InsomniaMRPheWAS/output/", sep="")

#Load package for fread
library(data.table)

#########################
# LOAD AND COMBINE DATA #
#########################

#Load variable Info and set columns names
setwd(paste(OUTPUT, "/analysis1/PHESANT/", sep=""))
Info<-fread("results-combined.txt", select=c(1,3,9,18,8), header=TRUE, data.table=F)
names(Info)<-c("Field_ID", "N", "Field_Name", "Path", "Regression_Type")

#Load An1 data and set column names
An1<-fread("results-combined.txt", select=c(1,4,5,6,7), header=TRUE, data.table=F)
names(An1)<-c("Field_ID", "S1_Beta", "S1_Lower", "S1_Upper", "S1_Pvalue")

#Load An2 data and set column names
setwd(paste(OUTPUT, "/analysis2/PHESANT/", sep=""))
An2<-fread("results-combined.txt", select=c(1,4,5,6,7), header=TRUE, data.table=F)
names(An2)<-c("Field_ID", "S2_Beta", "S2_Lower", "S2_Upper", "S2_Pvalue")

#Load An3 data and set column names
setwd(paste(OUTPUT, "/analysis3/PHESANT/", sep=""))
An3<-fread("results-combined.txt", select=c(1,4,5,6,7), header=TRUE, data.table=F)
names(An3)<-c("Field_ID", "Beta", "Lower", "Upper", "Pvalue")

#Merge Data
data_incomplete <- merge(Info, An3, by="Field_ID")
data_incomplete2 <- merge(data_incomplete, An1, by="Field_ID")
data <- merge(data_incomplete2, An2, by="Field_ID")

#####################
#  DELETE INSOMNIA  #
#####################

data <- subset(data, Field_ID!=1200)

#########################
# CREATE BON SIG VECTOR #
#########################


#Calculate Bonferroni Threshold
bonferroni <- 0.05/nrow(data)

#Create vector to assign significance
Sig<-vector(length=nrow(data))

#Assign a combination of 3 plusses or minusses to the Sig vector to describe the significance across the 3 analyses for each outcome 
for (i in 1:nrow(data)){
	if (data$Pvalue[i]<bonferroni){
                Sig[i]<-"+"
        } else {
                Sig[i]<-"-"
        }
	if (data$S1_Pvalue[i]<bonferroni){
                Sig[i]<-paste(Sig[i], "+", sep="")
        } else {
                Sig[i]<-paste(Sig[i], "-", sep="")
        }
	if (data$S2_Pvalue[i]<bonferroni){
                Sig[i]<-paste(Sig[i], "+", sep="")
        } else {
                Sig[i]<-paste(Sig[i], "-", sep="")
        }

}

#Print number of outcomes and print threshold
print(paste("N=", nrow(data), sep=""))
print(paste("Bonferroni=", bonferroni, sep=""))

#Add Sig vector to the data
data<-cbind(data, Sig)


#########################
# CREATE FDR SIG VECTOR #
#########################

#Make function
FDR <- function(P){
  
  #Sort by Pvalue
  data<<-data[order(P),]
  P<-sort(P)
    
  #Add significance signifier
  for (i in 1:nrow(data)){
    stop<-0
    if (P[i]<0.05*i/nrow(data) & stop==0){
      data$FDRSig[i] <<- paste(data$FDRSig[i], "+", sep="")
    } else {
      stop<-1
      data$FDRSig[i] <<- paste(data$FDRSig[i], "-", sep="")
    }
  }
}

#Make column
data$FDRSig<-""

#Run function
P<-data$Pvalue
FDR(P)
P<-data$S1_Pvalue
FDR(P)
P<-data$S2_Pvalue
FDR(P)

###################
# SIG VEN DIAGRAM #
###################

#Create vectors to make a table of patterns of sig results across all 3 analyses.
#This will be used to make ven diagram
sigpat<-c("+++", "++-", "+-+", "-++", "+--", "-+-", "--+")
analyses<-c("All", "Just_Main&S1", "Just_Main&S2", "Just_S1&S2", "Just_Main", "Just_S1", "Just_S2", "Any", "Any_Main", "Any_S1", "Any_S2")
number<-vector()
percent<-vector()

#Get total outcomes sig in 1 of the 3 analyses to calculate percent
subsetdata<-subset(data, Sig!="---")
total<-nrow(subsetdata)
print(paste("Total=", total, sep=""))

#Caculate number of sig results and percent of total for each individual section of ven diagram
for (i in 1:length(sigpat)){
        subsetdata<-subset(data, Sig==sigpat[i])
        number[i]<-nrow(subsetdata)
        percent[i]<-(number[i]/total)*100
}

#Create subsets to calculate number and percent for overall categories (i.e. each circle of ven diagram and total)
Any<-subset(data, Sig!="---")
Any_Main<-subset(data, Sig=="+--"|Sig=="++-"|Sig=="+++"|Sig=="+-+" )
Any_S1<-subset(data, Sig=="-+-"|Sig=="++-"|Sig=="+++"|Sig=="-++" )
Any_S2<-subset(data, Sig=="--+"|Sig=="+-+"|Sig=="+++"|Sig=="-++" )

#Caculate number of sig results and percent in each overall section and put in same vectors
a<-length(sigpat)+1 
for (i in a:length(analyses)){
        number[i]<-nrow(get(analyses[i]))
        percent[i]<-(number[i]/total)*100
}

#Bind table
VenTab<-data.frame(analyses, number, percent)

############################
# CREATE DIRECTION VECTOR  #
############################

#Create direction vector
Direction <- vector(length=nrow(data))

#Assign a combination of 3 plusses or minusses to the Direction vector to describe the direction of effect across the 3 analyses for each outcome
for (i in 1:nrow(data)){
        if (data$Beta[i]<0){
                Direction[i]<-"-"
        } else if (data$Beta[i]>0){
                Direction[i]<-"+"
        }
	if (data$S1_Beta[i]<0){
                Direction[i]<-paste(Direction[i], "-", sep="")
        } else if (data$S1_Beta[i]>0){
                Direction[i]<-paste(Direction[i], "+", sep="")
        }
	if (data$S2_Beta[i]<0){
                Direction[i]<-paste(Direction[i], "-", sep="")
        } else if (data$S2_Beta[i]>0){
                Direction[i]<-paste(Direction[i], "+", sep="")
        }
}

#Add vector to data
data<-cbind(data, Direction)


#####################
# CONVERT LOG TO OR #
#####################

#Split by regression type
print(nrow(data))
linear <- subset(data, Regression_Type=="LINEAR")
print(nrow(linear))
logistic <- subset(data, Regression_Type!="LINEAR")
print(nrow(logistic))

#Convert
logistic$Beta<-exp(logistic$Beta)
logistic$Lower<-exp(logistic$Lower)
logistic$Upper<-exp(logistic$Upper)
logistic$S1_Beta<-exp(logistic$S1_Beta)
logistic$S1_Lower<-exp(logistic$S1_Lower)
logistic$S1_Upper<-exp(logistic$S1_Upper)
logistic$S2_Beta<-exp(logistic$S2_Beta)
logistic$S2_Lower<-exp(logistic$S2_Lower)
logistic$S2_Upper<-exp(logistic$S2_Upper)

#Re-combine
data<-rbind(linear, logistic)
print(nrow(data))

#############
# SAVE DATA #
#############

setwd(OUTPUT)
write.table(data, "PHESANT-processed.txt", row.names=FALSE, sep = "\t", quote=FALSE)
write.table(VenTab, "VenDiagramTable.txt", row.names=FALSE, sep = "\t", quote=FALSE)
