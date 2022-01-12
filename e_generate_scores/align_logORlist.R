#Import HOME variable from bash
HOME=Sys.getenv("HOME")

#Put path in variable
INPUT=paste(HOME, "/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/inputs/", sep="")
 
#Load data.table package
library(data.table)

#Create function called align_ORlist with 'folder' as the input
align_LogORlist <- function(folder){

	#Set working directory
	setwd(INPUT)

	#Read LogORlist
	list<-fread(paste(folder, "/LogORlist-", folder, ".txt", sep=""), header=TRUE, data.table=F)

	#Set column names
	names(list)=c("rsid", "effect_allele", "other_allele", "LogOR", "EAF")

	#Make vector called direction which is the length of the number of snps
	direction<-vector(length = length(list$rsid))

	#Mark snps increasing or decreasing insomnia in the direction vector 
	for (i in 1:length(list$rsid)){
		if (list$LogOR[i]<0){
			direction[i] <- 0
		} else {
			direction[i] <- 1
		}
	}


	#Sanity check vector
	print(direction)
	print(length(direction))

	#Make vector of same length called 'pal'
	pal<-vector(length = length(list$rsid))

	#Mark snps as palindromic or not in pal vector
	for (i in 1:length(list$rsid)){
	        if ((list$effect_allele[i]=="A" & list$other_allele[i]=="T") | (list$effect_allele[i]=="T" & list$other_allele[i]=="A") | (list$effect_allele[i]=="C" & list$other_allele[i]=="G") | (list$effect_allele[i]=="G" & list$other_allele[i]=="C")){
	                pal[i] <- 1
	        } else {
			pal[i] <- 0
	        }
	}

	#Sanity check vector
	print(pal)
	print(length(pal))


	#Combine LogORList to direction vector and pal vector seperately (i.e. make two seperate tables). Then print these.
	origlist<-cbind(list, direction)
	print(origlist)
	list<-cbind(list, pal)
	print(list)

	#Use the list with direction to flip snps (invert EAF, LogOR and swap alleles) which decrease insomnia in the other list (the list with the pal vector)
	for (i in 1:length(list$rsid)){
		if (origlist$direction[i]==0){
			list$EAF[i]<- 1 - list$EAF[i]
        		list$LogOR[i]<- list$LogOR[i]*(-1)
        		temp<-list$effect_allele[i]
        		list$effect_allele[i]<-list$other_allele[i]
        		list$other_allele[i]<-temp
		}
	}

	#Print new list
	print(list)

	#Save both lists
	write.table(origlist, paste(folder, "/LogORlist-direction-", folder, ".txt", sep=""), row.names=FALSE, sep = " ", quote=FALSE)
	write.table(list, paste(folder, "/LogORlist-aligned-", folder, ".txt", sep=""), row.names=FALSE, sep = " ", quote=FALSE)
}

#Run for analysis 1
folder<-"analysis1"
align_LogORlist(folder)

#Run for analysis 2
folder<-"analysis2"
align_LogORlist(folder)

#Run for analysis 3
folder<-"analysis3"
align_LogORlist(folder)
