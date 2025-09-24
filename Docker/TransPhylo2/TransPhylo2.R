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
mcmc <- args[3]
w.shape <- args[4]
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

print("Output saved")

# Close log file
sink(type = "output")
sink(type = "message")
close(log_conn)