###Author: Samantha Malatesta
###Date: 09/25/2025
###Email: smalates@broadinstitute.org
###Purpose: Rscript for TransPhylo2 
###Inputs: dated tree, max date, mcmc, w.shape, w.scale, sample ids, swab dates

# Open log file
log_conn <- file("TransPhylo2.log", "w")
sink(log_conn, type = "output")
sink(log_conn, type = "message")

#record date and time 
Sys.time()

#Command Args
args <- commandArgs(trailingOnly = TRUE)
tree_file <- args[1]
max_date <- args[2]
mcmc <- as.numeric(args[3])
w.shape <- as.numeric(args[4])
w.scale <- as.numeric(args[5])

print("Check args correct")
tree_file
max_date
mcmc
w.shape
w.scale

#load packages
library(TransPhylo2)
library(ape)
library(dplyr)
library(lubridate)

#make df of dates and ids
ids_temp = read.table("ids.txt")
dates_temp = read.table("dates.txt")
meta = cbind(ids_temp, dates_temp)
colnames(meta) = c("id", "date")
meta$date <- as.numeric(meta$date)
print("IDs and dates")
head(meta)


#plot tree to check input 
t = readRDS(tree_file) 
plot(t)
print(t$tip.label)
print("Input tree")

#prep for TransPhylo2 run
meta_sub <- meta %>% filter(as.character(id) %in% t$tip.label) %>% select(id, date) %>% mutate(d=as.Date("2018-01-01")+(as.numeric(date)))
meta_sub$d <- decimal_date(meta_sub$d)
print(meta_sub)

lastSamp = as.numeric(max(meta_sub$d))

ptree<-ptreeFromPhylo(t,dateLastSample=lastSamp)

dateT= decimal_date(as.Date(max_date))

paste0("MCMC iterations ", mcmc, ", w.shape ", w.shape, ", w.scale ", w.scale, ", dateT ", dateT)

res<-inferTTree(ptree,mcmcIterations=mcmc,w.shape=w.shape,w.scale=w.scale,dateT=dateT)

print("Run TransPhylo2")

#save output
save(res,file=paste0( "transphylo2", "_results.rda") )

print("Output saved")

# Close log file
sink(type = "output")
sink(type = "message")
close(log_conn)