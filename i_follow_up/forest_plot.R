#Import HOME variable from bash
HOME=Sys.getenv("HOME")

#Put filepaths in variables
OUTPUT=paste(HOME, "/scratch/InsomniaMRPheWAS/output/", sep="")
INPUT=paste(HOME, "/scratch/InsomniaMRPheWAS/code/PHESANT-MR-PheWAS-Insomnia/inputs", sep="")

#Load packages
library(data.table)
library(ggplot2)
library(grid)
library(forcats)
library(stringr)

#############
# LOAD DATA #
#############

setwd(INPUT)
overlap<-fread("overlap.txt", header=TRUE, data.table=F)
FUcats<-fread("FUcats.txt", header=TRUE, data.table=F)

setwd(OUTPUT)
OR<-fread("FU-Full-OR.txt", header=TRUE, data.table=F)
MD<-fread("FU-Full-MD.txt", header=TRUE, data.table=F)

#########################
# STAR OVERLAP OUTCOMES #
#########################

for (i in 1: nrow(overlap)){
	if (overlap[i,2]=="MD"){
		j<-which(MD[,1]==overlap[i,1])
		MD[j,1]<-paste(MD[j,1], "*", sep="")
	}else{
		j<-which(OR[,1]==overlap[i,1])
		OR[j,1]<-paste(OR[j,1], "*", sep="")
	}
}

##################
# ADD CATEGORIES #
##################

#Split category file
FUcatsCont<-subset(FUcats, type=="Cont")
FUcatsBin<-subset(FUcats, type=="Binary")

#Merge with tables
MDcats<-merge(MD, FUcatsCont)
ORcats<-merge(OR, FUcatsBin)

#Check
missingMD<-setdiff(unique(MD$outcome), MDcats$outcome)
missingOR<-setdiff(unique(OR$outcome), ORcats$outcome)
print(missingMD)
print(missingOR)

#######################
# CLEAN OUTCOME NAMES #
#######################

#Make character vector
ORcats$outcome<-as.character(ORcats$outcome)

#Remove "+" and "Other" and make sure first letter is capital
for (i in 1:nrow(ORcats)){
	ORcats$outcome[i] <- str_remove(ORcats$outcome[i], "[+]")
	ORcats$outcome[i] <- gsub(pattern = "Other ", replacement = "", ORcats$outcome[i], perl = T)
	ORcats$outcome[i] <- gsub(pattern = "FG", replacement = "", ORcats$outcome[i], perl = T)
	ORcats$outcome[i] <- paste(toupper(substr(ORcats$outcome[i], 1, 1)), substr(ORcats$outcome[i], 2, nchar(ORcats$outcome[i])), sep="")
	ORcats$outcome[i] <- gsub(pattern = "ALCOHOLACUTE10", replacement = "", ORcats$outcome[i], perl = T)
	ORcats$outcome[i] <- gsub(pattern = "J10_COPDNAS", replacement = "", ORcats$outcome[i], perl = T)
	ORcats$outcome[i] <- gsub(pattern = "[()]", replacement = "", ORcats$outcome[i], perl = T)
}

#Add in units for continuous
cont<-subset(FUcats, type=="Cont")
for (i in 1:nrow(MDcats)){
	j<-which(MDcats$outcome==cont$outcome[i])
	MDcats$outcome[j]<-paste(MDcats$outcome[j], " (", cont$unit[i], ")", sep="")
}


##################
# FACTOR METHODS #
##################

MDcats$method<-fct_rev(MDcats$method)
ORcats$method<-fct_rev(ORcats$method)

##################
# FOREST PLOT MD #
##################

#Set values for dodge, text, labels and headers
pdl<-0.85
pdd<-0.65
ts<-12.5
ls<-4
et<-0.3

#Create forest plots, add dotted line at 0 on y axis, and flip axis, then set text size on Y axis
forest <- ggplot(MDcats, aes(x=fct_reorder(outcome, outcome, .desc=TRUE), y=b, ymin=lower, ymax=upper, colour=method)) +
  	geom_point(size=1, position = position_dodge(width=pdd)) +
  	geom_errorbar(width=et, position = position_dodge(width=pdd)) +
	geom_hline(yintercept=0, lty=2) +
	xlab("Outcome (Units)") + ylab("Mean Difference (95% CI)") +
	scale_x_discrete(labels = function(outcome) str_wrap(outcome, width = 40))+
 	geom_text(aes(label = paste(format(round(b, digits=2), nsmall = 2),
  		" (",
        	format(round(lower, digits=2), nsmall = 2),
        	", ",
        	format(round(upper, digits=2), nsmall = 2),
        	")",
        	sep=""), y = -4.25, x = outcome, group = method), 
        	position = position_dodge(width = pdl), colour="black", size=ls) +
  	facet_grid(rows = vars(category), 
        	scales = "free_y",
        	space = "free_y",
        	switch = "y") +
  	coord_flip(ylim = c(-5,2), expand=0) +
  	theme(axis.text.y=element_text(size=ts), legend.title = element_blank(), legend.text=element_text(size=ts), legend.position="bottom",
		axis.title.y=element_text(size=ts, vjust=10, face="bold"), axis.text.x=element_text(size=ts), axis.title.x=element_text(size=ts, vjust=-2, face="bold"),
        	strip.placement = "outside", strip.background = element_rect(fill = "white"), 
        	strip.text.y.left = element_text(size=ts, angle = 0, hjust=0, face="bold"),
		panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
		plot.margin=unit(c(2,2,2,2), "cm"))+
		guides(colour = guide_legend(reverse = TRUE))
ggsave("FP_MD.jpg", width = 15, height = 17.5)

##################
# FOREST PLOT OR #
##################

#Set uplim
uplim<-5

#Create arrowY
for (i in 1:nrow(ORcats)){
	if (ORcats$upper[i] > uplim){
		ORcats$arrowY[i]<-uplim - 0.05
	}else{
		ORcats$arrowY[i]<-uplim + 4
	}
}

#Split
ORcats1<-subset(ORcats, category %in% c("Body Composition/Metabolic", "Cardiovascular", "Digestive", "Headache", "Immune"))
ORcats2<-subset(ORcats, !(category %in% c("Body Composition/Metabolic", "Cardiovascular", "Digestive", "Headache", "Immune")))

#Create forest plots, add dotted line at 1 on y axis, and flip axis, then set text size on Y axis
tab<-c("ORcats1", "ORcats2")
for (i in 1:length(tab)){
	forest <- ggplot(get(tab[i]), aes(x=fct_reorder(outcome, outcome, .desc=TRUE), y=b, ymin=lower, ymax=upper, colour=method)) +
		geom_point(size=1, position = position_dodge(width=pdd)) +
		geom_errorbar(width=et, position = position_dodge(width=pdd)) +
		geom_hline(yintercept=1, lty=2) +	
		geom_text(aes(label=">", x=outcome, y=arrowY), vjust=.42, size=4.5, position = position_dodge(width=pdd), show.legend = FALSE) +
		xlab("Outcome") + ylab("Odds Ratio (95% CI)") +
	        scale_x_discrete(labels = function(outcome) str_wrap(outcome, width = 40))+
		geom_text(aes(label = paste(format(round(b, digits=2), nsmall = 2), 
			" (", 
			format(round(lower, digits=2), nsmall = 2), 
			", ", 
			format(round(upper, digits=2), nsmall = 2), 
			")", 
			sep=""), y = -0.5, x = outcome, group = method), 
			position = position_dodge(width = pdl), colour="black", size=ls) +
		  facet_grid(rows = vars(category), 
	             scales = "free_y",
	             space = "free_y",
	             switch = "y") +
	        coord_flip(ylim=c(-1, uplim), expand=0) +
		theme(axis.text.y=element_text(size=ts), legend.title = element_blank(), legend.text=element_text(size=ts), legend.position="bottom",
			axis.title.y=element_text(size=ts, vjust=10, face="bold"), axis.text.x=element_text(size=ts), axis.title.x=element_text(size=ts, vjust=-2, face="bold"),
	        	strip.placement = "outside", strip.background = element_rect(fill = "white"), 
	        	strip.text.y.left = element_text(size=ts, angle = 0, hjust=0, face="bold"),
			panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
			plot.margin=unit(c(2,2,2,2), "cm"))+
			guides(colour = guide_legend(reverse = TRUE))
	ggsave(paste("FP_OR", i, ".jpg", sep=""), width = 15, height = 17.5)
}
