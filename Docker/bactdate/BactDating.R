# Open log file
log_conn <- file("BactDate.log", "w")
sink(log_conn, type = "output")
sink(log_conn, type = "message")

#install and load packages
install.packages("devtools")
devtools::install_github("xavierdidelot/BactDating")
install.packages("ape")


library(BactDating)
library(ape)

#change file extensions to make BactDating happy
files <- list.files(pattern="*.nwk")
newfiles <- gsub(".nwk$", ".tre", files)
file.rename(files, newfiles)

#needs .csv even though tab delimited in source code
files <- list.files(pattern="*.tsv")
newfiles <- gsub(".tsv$", ".csv", files)
file.rename(files, newfiles)

#prefix for Gubbins 
prefix = sub("\\..*", "", list.files(pattern="*polymorphic_sites.fasta"))

#load Gubbins output
t=loadGubbins(prefix)

#remove reference tip
t <- drop.tip(t, tip = "Reference")

#plot input tree and save
png(paste0(prefix, "_input_tree.png"))
plot(t)
dev.off()

# Close log file
sink(type = "output")
sink(type = "message")
close(log_conn)