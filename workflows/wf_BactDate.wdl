version 1.0

task BactDate_script {
input {
    Array[String] ids
    Array[String] sample_dates
    File gubbins_filtered_polymorphic_sites
    File gubbins_final_tree
    File gubbins_node_labelled_final_tree
    File gubbins_per_branch_statistics
    File gubbins_recombination_predictions
    File Rscript
    Int mcmc
    String model

  }
    command <<<
    # Copy the R script and input data (if provided) to the task's working directory
    cp ~{Rscript} .
    
    cp ~{gubbins_filtered_polymorphic_sites} .
    cp ~{gubbins_final_tree} .
    cp ~{gubbins_node_labelled_final_tree} .
    cp ~{gubbins_per_branch_statistics} .
    cp ~{gubbins_recombination_predictions} .

       
    declare -a bash_array=(~{sep=" " ids})
    printf "%s\n" "${bash_array[@]}" > ids.txt
    declare -a bash_array=(~{sep=" " sample_dates})
    printf "%s\n" "${bash_array[@]}" > dates.txt

        Rscript BactDating.R "~{model}" \
           "ids.txt" \
            "dates.txt" \
            ~{mcmc} \
             ~{gubbins_filtered_polymorphic_sites} \
            ~{gubbins_final_tree} \
            ~{gubbins_node_labelled_final_tree} \
            ~{gubbins_per_branch_statistics} \
            ~{gubbins_recombination_predictions} \ 
             
    >>>
        output {
            File stdout = stdout()
            File rlog = "BactDate.log"
            String model_out = "~{model}"
            Array[File] gubbins_tree = glob("*_gubbins_tree.pdf")
            Array[File] mcmc_trace = glob("*_trace.pdf")
            Array[File] dated_tree = glob("*_bactdate_tree.pdf")
            Array[File] nwktree = glob("*_dated_tree.nwk")
            
        }
  runtime {
    docker: "rocker/r-ver:latest" 
  }
}


# Define the workflow that uses the task
workflow BactDate {
  input {
    Array[String] ids
    Array[String] sample_dates
    File gubbins_filtered_polymorphic_sites
    File gubbins_final_tree
    File gubbins_node_labelled_final_tree
    File gubbins_per_branch_statistics
    File gubbins_recombination_predictions
    File Rscript
    Int mcmc
    String model
  }

  call BactDate_script{
    input: ids=ids, sample_dates=sample_dates, model=model, mcmc=mcmc, gubbins_filtered_polymorphic_sites = gubbins_filtered_polymorphic_sites, gubbins_final_tree=gubbins_final_tree, gubbins_node_labelled_final_tree=gubbins_node_labelled_final_tree, gubbins_per_branch_statistics=gubbins_per_branch_statistics, gubbins_recombination_predictions=gubbins_recombination_predictions, Rscript=Rscript
  }

  output {
    Array[File] input_tree = BactDate_script.gubbins_tree
    File rLog = BactDate_script.rlog
    File out = BactDate_script.stdout
    String model_out = BactDate_script.model_out
    Array[File] dated_tree = BactDate_script.dated_tree
    Array[File] mcmc_trace = BactDate_script.mcmc_trace
    Array[File] nwktree = BactDate_script.nwktree
  }
}

