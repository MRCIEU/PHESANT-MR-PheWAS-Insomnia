#Import HOME variable from bash
HOME=Sys.getenv("HOME")

#Put path in variable
DATA=paste(HOME, "/scratch/InsomniaMRPheWAS/data/", sep="")

#Load data.table package
library(data.table)

#Set working directory
setwd(DATA)

#Read the participant IDs
sample<-fread("sample.txt", select=2, skip=2, header=FALSE, data.table=F)

#Rows = 463005
print(nrow(sample))

#Make column name same as linker file
names(sample)=c("appieu")

#Read linker
linker<-fread("linker.txt", header=TRUE, data.table=F)

#Set column names
names(linker)<-c("eid", "appieu")

#Rows = 463005
print(nrow(linker))

#Create function called add_IDs with 'folder' as the input.
add_IDs <- function(folder){

	#Set working directory to specific analysis folder
	setwd(paste(DATA, folder, sep=""))

	#Read data
	data<-fread(paste("data-transposed-", folder, ".txt", sep=""), header=TRUE, data.table=F)

	#Combine IDs with data
	data <- cbind(sample, data)

	#Rows = 463005
	print(nrow(data))

	#Merge with linker
	data <- merge(linker, data, by="appieu")

	#Rows = 463005
	print(nrow(data))

	#Save data
	write.table(data, paste("data-IDs-", folder, ".txt", sep=""), row.names=FALSE, sep = " ", quote=FALSE)
}

#Run for analysis 1 (identical to Analysis 2)
folder<-"analysis1"
add_IDs(folder)

#Run for analysis 3
folder<-"analysis3"
add_IDs(folder)
