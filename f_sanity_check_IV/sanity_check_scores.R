#Import HOME variable
HOME=Sys.getenv("HOME")

#Put paths in variables
DATA=paste(HOME, "/scratch/InsomniaMRPheWAS/data", sep="")
OUTPUT=paste(HOME, "/scratch/InsomniaMRPheWAS/output", sep="")
LIB<-paste(HOME, "/R/x86_64-pc-linux-gnu-library/4.0", sep="")

#Set working directory
setwd(DATA)

#Load packages
library(data.table)
library(ggplot2)
.libpaths=LIB
library(DescTools, lib=LIB)

#############
# READ DATA #
#############

#Read insomnia data (502505 rows) and set column names (show first 6 rows as sanity check)
insom<-fread("insomnia.txt", header=TRUE, data.table=F)
names(insom)=c("eid", "sex", "insomnia", "age")
print(nrow(insom))
head(insom)

#Read Principal component data (488377 rows) and set names (show first 6 rows as sanity check)
PC<-fread("PC.txt", header=FALSE, data.table=F)
names(PC)=c("appieu", "PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8", "PC9", "PC10")
print(nrow(PC))
head(PC)

#Read scores
scores_analysis1<-fread("analysis1/scores-analysis1.txt", header=TRUE, data.table=F)
scores_analysis2<-fread("analysis2/scores-analysis2.txt", header=TRUE, data.table=F)
scores_analysis3<-fread("analysis3/scores-analysis3.txt", header=TRUE, data.table=F)

#Name score columns
names(scores_analysis1)<-c("appieu", "eid", "analysis1")
names(scores_analysis2)<-c("appieu", "eid", "analysis2")
names(scores_analysis3)<-c("appieu", "eid", "analysis3")

#Merge scores and save
scores<-merge(scores_analysis1, scores_analysis2)
scores<-merge(scores, scores_analysis3)
write.table(scores, "all-scores.txt", row.names=FALSE, sep = " ", quote=FALSE)

#########################
# PROCESS INSOMNIA DATA #
#########################

#Remove missing data (501001)
insom <- subset(insom, insomnia==1| insomnia==2| insomnia==3)
print(nrow(insom))
head(insom)

#Make data binary by getting index of 3s and 1or2s and changing to 1 and 0 respectively. 
#Then make this column a factor and check number of rows remains same.
usually<-which(insom$insomnia==3)
some_never <- which(insom$insomnia!=3)
insom$insomnia[usually] <- 1
insom$insomnia[some_never] <- 0
insom$insomnia <- factor(insom$insomnia)
print(nrow(insom))
head(insom)

##############
# Merge Data #
##############

#Merge scores with Principal components (rows = 336992 after merge)
scores <- merge(PC, scores, by="appieu")
print(nrow(scores))

#Merge with Insomnia (rows = 336757)
scoresinsom <- merge(insom, scores, by="eid")
print(nrow(scoresinsom))

#Make table of confounders and save it
confounders<-scoresinsom[,c("eid","age","sex","PC1","PC2","PC3","PC4","PC5","PC6","PC7","PC8","PC9","PC10")]
write.table(confounders, "confounders.csv", row.names=FALSE, sep = ",", quote=FALSE)

#Remove Scores and save it
insomnia_processed <- scoresinsom[,c("eid","appieu","age","sex","PC1","PC2","PC3","PC4","PC5","PC6","PC7","PC8","PC9","PC10","insomnia")] 
write.table(insomnia_processed, "insomnia-processed.txt", row.names=FALSE, sep = " ", quote=FALSE)

#########################
# REGRESS WITH INSOMNIA #
#########################

#Create a function called sanity_check_scores with the inputs folder and analysis
sanity_check_scores <- function(folder) {


	#Create histogram of standardised scores
	p <- ggplot(scores, aes(x=get(folder))) + geom_histogram()
	setwd(OUTPUT)
	ggsave(paste(folder, "/sancheck/graphs/histogram-", folder, ".jpg", sep=""), p)


	#Regress insomnia on scores (logistic) and extract results
	logit <- glm(insomnia ~ get(folder) + age + sex  + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10, data = scoresinsom, family = "binomial")
	coefficient <- coef(logit)["get(folder)"]
	cis<-confint(logit, "get(folder)", level=0.95)
	lower <- cis["2.5 %"]
	upper <- cis["97.5 %"]
	summary <- summary(logit)
	summary <- summary$coefficients
	pvals <- summary[,"Pr(>|z|)"]
	p <- pvals["get(folder)"]
	R2<-PseudoR2(logit, which = "McFadden")

	#Convert log odds to odds
	coefficient <- exp(coefficient)
	lower <- exp(lower)	
	upper <- exp(upper)

	#Create results table and save
	regression<-cbind(coefficient, lower, upper, p, R2)
	write.table(regression, paste(folder, "/sancheck/logitstic-regression-", folder, ".txt", sep=""), row.names=FALSE, sep = " ", quote=FALSE)
}

#Run for analysis 1
folder<-"analysis1"
sanity_check_scores(folder)

#Run for analysis 2
folder<-"analysis2"
sanity_check_scores(folder)

#Run for analysis 3
folder<-"analysis3"
sanity_check_scores(folder)

##################################
# REGRESS SCORES WITH EACH OTHER #
##################################

#Create vectors for loop
an1<-scores$analysis1
an2<-scores$analysis2
an3<-scores$analysis3
exp<-c("an1", "an1", "an2")
out<-c("an2", "an3", "an3")
upper<-vector()
lower<-vector()
cor<-vector()

for (i in 1:length(exp)){
	#Run regressions
	fit <- cor.test(get(exp[i]), get(out[i]), method = "pearson")
	cor[i] <- fit$estimate
	lower[i] <- fit$conf.int[1]
	upper[i] <- fit$conf.int[2]
}

#Bind and write table
score_cor<-data.frame(exp, out, cor, lower, upper)
write.table(score_cor, "score-correlations.txt", row.names=FALSE, sep = " ", quote=FALSE)

