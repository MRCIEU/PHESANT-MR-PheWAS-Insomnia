#Import HOME variable bash
HOME=Sys.getenv("HOME")

#Put path in variable
DATA=file.path(HOME, "/scratch/InsomniaMRPheWAS/data/")

#Load data.table package
library(data.table)

#Set working directory
setwd(DATA)

#Create function called transpose with the input "folder"
transpose <- function(folder) {

	#Read dosage data
	data<-fread(paste(folder, "/snps-dosage2-", folder, ".txt", sep=""), header=FALSE, data.table=F)

	#Get number of rows
	print(nrow(data))

	#Read list of rsids
	snps<-fread(paste(folder, "/snps-dosage-", folder, ".txt", sep=""), select=3, header=FALSE, data.table=F)

	#Get number of rows
	print(nrow(snps))


	#Transpose data
	data<-t(data)

	#Get number of rows = 463005 participants
	print(nrow(data))

	#Get column number (i.e. snps)
	print(ncol(data))

	#Make rsids column names
	colnames(data)<-snps[,1]

	#Save data
	write.table(data, paste(folder, "/data-transposed-", folder, ".txt", sep=""), row.names=FALSE, sep = " ", quote=FALSE)
}

#Run for analysis 1 (identical for analysis 2). Rows = 111 snps
folder<-"analysis1"
transpose(folder)

#Run for analysis 3. Rows = 129 snps
folder<-"analysis3"
transpose(folder)


