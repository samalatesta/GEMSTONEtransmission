###Author: Samantha Malatesta
###Date: 09/12/2025
###Email: smalates@broadinstitute.org
###Purpose: Rscript for TransPhylo2 
###Inputs: dated tree, max date, mcmc, w.shape, w.scale

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

#plot tree to check input 
t = read.tree(tree_file)
plot(t)
print("Input tree")

ptree<-ptreeFromPhylo(t,dateLastSample=2007.94)

dateT=2008

res<-inferTTree(ptree,mcmcIterations=1000,w.shape=w.shape,w.scale=w.scale,dateT=dateT)

print("Run TransPhylo2")

#save output
save(res,file=paste0( "transphylo2", "_results.rda") )


print("Output saved")

# Close log file
sink(type = "output")
sink(type = "message")
close(log_conn)