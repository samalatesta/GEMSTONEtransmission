version 1.0

task BactDate_script {
  input {
    File gubbins_filtered_polymorphic_sites
    File gubbins_final_tree
    File gubbins_node_labelled_final_tree
    File gubbins_filtered_polymorphic_sites
    File gubbins_per_branch_statistics
    File gubbins_recombination_predictions
  }

    command<<<
    # I would wrap this in quotes to prevent any side effects of 
    # shell expansion
    R --no-save <<Rscript
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
    Rscript
  >>>

  output {
    File gubbins_tree = glob("*tree.png")
    File rLog = "BactDate.log"
  }

  runtime {
    docker: "rocker/tidyverse:latest" 
  }
}


# Define the workflow that uses the task
workflow BactDate {
  input {
    File gubbins_filtered_polymorphic_sites
    File gubbins_final_tree
    File gubbins_node_labelled_final_tree
    File gubbins_filtered_polymorphic_sites
    File gubbins_per_branch_statistics
    File gubbins_recombination_predictions
  }

  call BactDate_script

  output {
    File input_tree = BactDate_script.gubbins_tree
    File rLog = BactDate_script.rLog
  }
}

