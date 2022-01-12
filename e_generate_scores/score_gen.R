#Import HOME variable from Bash
HOME=Sys.getenv("HOME")

#Put path in variable
DATA=paste(HOME, "/scratch/InsomniaMRPheWAS/data/", sep="")

#Load data.table package
library(data.table)

#Create a function called score_gen which takes the input 'folder'
score_gen <- function(folder){

	#Set working directory
	setwd(paste(DATA, folder, sep=""))

	#Read transposed data 
	data<-fread(paste("data-excld-", folder, ".txt", sep=""), header=TRUE, data.table=F)

	#Seperate IDs in new data frame
	IDs<-data[,c(1,2)]
	data<-data[,-c(1,2)]

	#Read UKB SNP info
	snp_summary_stats<-fread(paste("snp-summary-stats-", folder, ".txt", sep=""), header=TRUE, data.table=F)
	print(snp_summary_stats)

	#Make vector for scores which is the length of the data (participants)
	scores <- vector(length=length(data[,1]))
	scores <- 0

	#For each snp in the data
	#If direction is matched take dosages for snp for all participants from UK biobank.
	#If direction is not matched invert dosages and take that.
	#If direction unspecified ('True' plaindromic) make dosage 0 and mark snp as exclued in snp name
	#Then use the dosage and the logOR for the snp to calculate the score for that one snp for each participants and add it to the overall score of each particpant 
	for (i in 1:length(snp_summary_stats$rsid)){ 
		if (snp_summary_stats$direction[i]==2){
			dosage <- data[,i]
                } else if (snp_summary_stats$direction[i]==1){
			dosage <- 2 - data[,i]
			data[,i] <- 2 - data[,i]
		} else if (snp_summary_stats$direction[i]==0){
			dosage <- 0
			snp_summary_stats$rsid[i]<-paste(snp_summary_stats$rsid[i], "_excluded", sep="")
		}
	
		#Make dosage numeric
		dosage <- as.numeric(dosage)

		#Calculate scores (the dosages in each column multiplied by the effect of that snp on insomnia, summed across all columns)
		scores <- scores + (dosage * snp_summary_stats$logOR_GWAS[i])
	}	

	#Numerise scores and print length as sanity check (336992)
	scores <- as.numeric(scores)
	scores <- scale(scores)
	print(length(scores))

	#Bind scores to IDs and save
	scores<-cbind(IDs, scores)
	write.table(scores, paste("scores-", folder, ".txt", sep=""), row.names=FALSE, sep = " ", quote=FALSE)

	#Delete genetic IDs and resave
	scoresPHESANT<-scores[,c(2,3)]
	write.table(scoresPHESANT, paste("scores-PHESANT-", folder, ".csv", sep=""), row.names=FALSE, sep = ",", quote=FALSE)

	#Change column names in data to include whether the snp is excluded or not.
	names(data)<- snp_summary_stats$rsid

	#Re-add IDs
	data <-cbind(IDs, data)

	#Save data
	write.table(data, paste("data-aligned-", folder,  ".txt", sep=""), row.names=FALSE, sep = " ", quote=FALSE )
}

#Run for analysis 1
folder<-"analysis1"
score_gen(folder)

#Run for analysis 2
folder<-"analysis2"
score_gen(folder)

#Run for analysis 3
folder<-"analysis3"
score_gen(folder)
