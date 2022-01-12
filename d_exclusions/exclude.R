#Import HOME variable from bash
HOME=Sys.getenv("HOME")

#Put path in variable
DATA=paste(HOME, "/scratch/InsomniaMRPheWAS/data/", sep="")

#Load packages
library(data.table)
library(dplyr)

#Set working directory
setwd(DATA)

#Reads list of British IDs, Related IDs and Withdrawn IDs
WB<-fread("WB.txt", header=FALSE, data.table=F)
related<-fread("related.txt", header=FALSE, data.table=F)
withdraw<-fread("withdrawals.txt", header=FALSE, data.table=F)

#Make col names the same as column in linker file
names(WB)=c("appieu")
names(related)=c("appieu")
names(withdraw)<- "eid"

#Create functioncalled exclude with input 'folder'
exclude <- function(folder){

	#Set working directory to specific analysis folder
	setwd(paste(DATA, folder, sep=""))

	#Read data
	data<-fread(paste("data-IDs-", folder, ".txt", sep=""), header=TRUE, data.table=F)

	#Merge with white-British ID (exclude those not in list) list and print new number of rows
	data <- merge(WB, data, by="appieu")
	# Rows = 408186 rows
	print("British data")
	print(nrow(data))

	#Exclude related individuals and print new number of rows
	data <- anti_join(data,related,by="appieu")
	#Rows = 337014
	print("unrelated data")
	print(nrow(data))

	#Exclude Witdrawn individuals and print new number of rows
	data <- anti_join(data,withdraw,by="eid")
	# Rows = 337001
	print("unwithdrawn data")
	print(nrow(data))

	#Save data
	write.table(data, paste("data-excld-", folder, ".txt", sep=""), row.names=FALSE, sep = " ", quote=FALSE)
}


#Run for analysis 1 (identical to 2).
#Rows of data at start = 463005
#Rows of output after exclusion of non-British = 408186
#Rows of output after exclusion of related = 337014
#Rows of output after withdrawals = 336992
folder<-"analysis1"
exclude(folder)

#Run for analysis 3
#Participant numbers same as analysis 1 at each stage
folder<-"analysis3"
exclude(folder)

