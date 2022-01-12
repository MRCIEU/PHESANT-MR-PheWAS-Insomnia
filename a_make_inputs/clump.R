#Import Home varible from bash which contains the filepath to my section of BC4
HOME=Sys.getenv("HOME")

#Put filepaths in variables
LIB<-paste(HOME, "/R/x86_64-pc-linux-gnu-library/4.0", sep="")
DATA<-paste(HOME, "/scratch/InsomniaMRPheWAS/data", sep="")

#Set library and load packages
.libpaths=LIB
library(data.table, lib=LIB)
library(TwoSampleMR, lib=LIB)

#Set working directory
setwd(DATA)

#Read data
data<-fread("unclumpedsnps.txt", header=TRUE, data.table=F)

#Clump
clumpeddata<- clump_data(data, clump_kb = 10000, clump_r2 = 0.001, clump_p1 = 1, clump_p2 = 1, pop = "EUR")

#Save data
write.table(clumpeddata, "clumpedsnps.txt", row.names=FALSE, sep = " ", quote=FALSE)

