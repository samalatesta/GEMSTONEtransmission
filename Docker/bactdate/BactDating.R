###Author: Samantha Malatesta
###Date: 08/21/2025
###Email: smalates@broadinstitute.org
###Purpose: Rscript for BactDating 
###Inputs: useRec, Gubbins files or Snippy tree, mcmc iters, id and date arrays, model specification

# Open log file
log_conn <- file("BactDate.log", "w")
sink(log_conn, type = "output")
sink(log_conn, type = "message")

#record date and time 
Sys.time()

#Command Args
args <- commandArgs(trailingOnly = TRUE)
useRec <- args[1]
model_arg <- args[2]
ids <- args[3]
dates <- args[4]
mcmc_arg <- as.numeric(args[5])

if(useRec == "true"){
file1 <- args[7]
file2 <- args[8]
file3 <-  args[9]
file4 <- args[10]
file5 <- args[11]
}

if(useRec == "false"){
  file1 <- args[6]
  file2 <- NA
  file3 <-  NA
  file4 <- NA
  file5 <- NA
}
print("Check args correct")
useRec
model_arg
ids
dates
mcmc_arg
file1
file2
file3
file4
file5

#load packages
library(BactDating)
library(ape)
library(dplyr)

#make df of dates and ids
ids_temp = read.table("ids.txt")
dates_temp = read.table("dates.txt")
meta = cbind(ids_temp, dates_temp)
colnames(meta) = c("id", "date")
meta$date <- as.Date(meta$date)
print("IDs and dates")
head(meta)

#if useRec is true then load Gubbins files 
if(useRec == "true"){
print("Using Gubbins")
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

#load Gubbins output
t=loadGubbins(prefix)
print("Gubbins loaded")

}

#if useRec is false then use Snippy tree 
if(useRec == "false"){
print("Using Snippy tree")
temp=list.files(pattern="*.nwk")

prefix = sub("\\..*", "", list.files(pattern="*.nwk"))
print(paste0("Prefix is ", prefix))

t = read.tree(temp)
}


#remove reference tip
t <- drop.tip(t, tip = "Reference")

meta_sub <- meta %>% filter(id %in% t$tip.label) %>% select(id, date) %>% mutate(d=2018+((as.numeric(date)-min(as.numeric(date)))/365))

#make date vector
d=meta_sub$d

print(d)

#make names of d the id names
names(d) <-meta_sub$id

#make indicator if gubbins should be used
gubbins = ifelse(useRec== "true", T, F)

#root tree using linear regression analysis 
rooted=initRoot(t, d, mtry = 100, useRec = gubbins)

#run bactdate
res=bactdate(rooted,d,nbIts = mcmc_arg, showProgress = F, useRec = gubbins, model=model_arg)
print("BactDate run complete")

#plot root to tip analysis
pdf(paste0( prefix, "_roottotip.pdf"))
roottotip(rooted, d)
dev.off()

#plot input tree and save
pdf(paste0( prefix, "_input_tree.pdf"))
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

#save mcmc code to R object for post hoc analysis
mcmc = as.mcmc.resBactDating(res, burnin = 0.5)
save(mcmc, file= paste0(prefix, "_mcmc.rda"))
print("MCMC saved")

#nwk for dated tree
dated=as.treedata.resBactDating(res)
save(dated,file=paste0( prefix, "_dated_tree.rda") )

#estimated dates and confidence intervals
date=c(leafDates(res$tree), nodeDates(res$tree))
lb = res$CI[,1]
ub = res$CI[,2]
write.table(data.frame(date, lb, ub), paste0( prefix, "_node_dates.txt"), row.names = F )

print("Output saved")

# Close log file
sink(type = "output")
sink(type = "message")
close(log_conn)