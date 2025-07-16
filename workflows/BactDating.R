###Author: Samantha Malatesta
###Date: 07/15/2025
###Email: smalates@broadinstitute.org
###Purpose: Rscript for BactDating 
###Inputs: Gubbins files, mcmc iters, id and date arrays, model specification

# Open log file
log_conn <- file("BactDate.log", "w")
sink(log_conn, type = "output")
sink(log_conn, type = "message")

#record date and time 
Sys.time()

#Command Args
args <- commandArgs(trailingOnly = TRUE)
model_arg <- args[1]
ids <- args[2]
dates <- args[3]
mcmc_arg <- as.numeric(args[4])
file1 <- args[5]
file2 <- args[6]
file3 <-  args[7]
file4 <- args[8]
file5 <- args[9]

print("Check args correct")
model_arg
ids
dates
mcmc_arg
file1
file2
file3
file4
file5

#install and load packages
#install.packages("devtools")
#devtools::install_github("xavierdidelot/BactDating")
#install.packages("ape")

library(BactDating)
library(ape)
library(dplyr)

#change file extensions to make BactDating happy
files <- list.files(pattern="*.nwk")
print(files)
newfiles <- gsub(".nwk$", ".tre", files)
file.rename(files, newfiles)

#needs .csv even though tab delimited in source code
files <- list.files(pattern="*.tsv")
print(files)
newfiles <- gsub(".tsv$", ".csv", files)
file.rename(files, newfiles)

#prefix for Gubbins 
prefix = sub("\\..*", "", list.files(pattern="*polymorphic_sites.fasta"))
print(paste0("Prefix is ", prefix))

#make df of dates and ids
ids_temp = read.table("ids.txt")
dates_temp = read.table("dates.txt")
meta = cbind(ids_temp, dates_temp)
colnames(meta) = c("id", "date")
meta$date <- as.Date(meta$date)
print("IDs and dates")
head(meta)

#load Gubbins output
t=loadGubbins(prefix)
print("Gubbins loaded")

#remove reference tip
t <- drop.tip(t, tip = "Reference")

meta_sub <- meta %>% filter(id %in% t$tip.label) %>% select(id, date) %>% mutate(d=as.numeric(date)/365)

#make date vector
d=meta_sub$d

#make names of d the id names
names(d) <-meta_sub$id

#run bactdate
res=bactdate(t,d,nbIts = mcmc_arg, showProgress = F, useRec = T, model=model_arg)
print("BactDate run complete")

#plot input tree and save
pdf(paste0( prefix, "_gubbins_tree.pdf"))
plot(t)
dev.off()

#plot trace and save
pdf(paste0( prefix, "_trace.pdf"))
plot(res, type="trace")
dev.off()

#plot dated tree
pdf(paste0( prefix, "_bactdate_tree.pdf"))
plot(res, type="tree")
dev.off()

#nwk for dated tree
write.tree(res$tree,paste0( prefix, "_dated_tree.nwk") )

print("Output saved")

# Close log file
sink(type = "output")
sink(type = "message")
close(log_conn)