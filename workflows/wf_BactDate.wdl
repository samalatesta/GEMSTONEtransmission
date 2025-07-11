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

  command <<<
    Rscript /scripts/BactDating.R \
      ~{gubbins_filtered_polymorphic_sites} \
      ~{gubbins_final_tree} \
      ~{gubbins_node_labelled_final_tree} \
      ~{gubbins_per_branch_statistics} \
      ~{gubbins_recombination_predictions} \
      ~{gubbins_recombination_predictions}
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

  call BactDate_script {}

  output {
    File input_tree = BactDate_script.gubbins_tree
    File rLog = BactDate_script.rLog
  }
}

