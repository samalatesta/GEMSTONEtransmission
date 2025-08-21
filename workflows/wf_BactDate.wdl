version 1.0

task BactDate_script {
input {
    Array[String] ids
    Array[String] sample_dates
    String useRec
    File? gubbins_filtered_polymorphic_sites
    File? gubbins_final_tree
    File? gubbins_node_labelled_final_tree
    File? gubbins_per_branch_statistics
    File? gubbins_recombination_predictions
    File? input_tree
    Int mcmc
    String model

  }
    command <<<

    cp ~{gubbins_filtered_polymorphic_sites} .
    cp ~{gubbins_final_tree} .
    cp ~{gubbins_node_labelled_final_tree} .
    cp ~{gubbins_per_branch_statistics} .
    cp ~{gubbins_recombination_predictions} .
    cp ~{input_tree} .

       
    declare -a bash_array=(~{sep=" " ids})
    printf "%s\n" "${bash_array[@]}" > ids.txt
    declare -a bash_array=(~{sep=" " sample_dates})
    printf "%s\n" "${bash_array[@]}" > dates.txt

        Rscript /app/BactDating.R "~{useRec}" \
           "~{model}" \
           "ids.txt" \
            "dates.txt" \
            ~{mcmc} \
            ~{input_tree} \
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
            Array[File] initial_tree = glob("*_input_tree.pdf")
            Array[File] mcmc_trace = glob("*_trace.pdf")
            Array[File] dated_tree = glob("*_bactdate_tree.pdf")
            Array[File] nwktree = glob("*_dated_tree.rda")
            Array[File] mcmc_out = glob("*_mcmc.rda")
            Array[File] estdates = glob("*_dates.txt")
            Array[File] rtt = glob("*_roottotip.pdf")
            
        }
  runtime {
    docker: "samalate/bactdate:v1.3" 
  }
}


# Define the workflow that uses the task
workflow BactDate {
  input {
    Array[String] ids
    Array[String] sample_dates
    String useRec
    File? gubbins_filtered_polymorphic_sites
    File? gubbins_final_tree
    File? gubbins_node_labelled_final_tree
    File? gubbins_per_branch_statistics
    File? gubbins_recombination_predictions
    File? input_tree
    Int mcmc
    String model
  }

  call BactDate_script{
    input: ids=ids,useRec=useRec,input_tree=input_tree, sample_dates=sample_dates, model=model, mcmc=mcmc, gubbins_filtered_polymorphic_sites = gubbins_filtered_polymorphic_sites, gubbins_final_tree=gubbins_final_tree, gubbins_node_labelled_final_tree=gubbins_node_labelled_final_tree, gubbins_per_branch_statistics=gubbins_per_branch_statistics, gubbins_recombination_predictions=gubbins_recombination_predictions
  }

  output {
    Array[File] input_tree = BactDate_script.initial_tree
    File rLog = BactDate_script.rlog
    File out = BactDate_script.stdout
    String model_out = BactDate_script.model_out
    Array[File] dated_tree = BactDate_script.dated_tree
    Array[File] mcmc_trace = BactDate_script.mcmc_trace
    Array[File] nwktree = BactDate_script.nwktree
    Array[File] mcmc_output = BactDate_script.mcmc_out
    Array[File] tree_dates = BactDate_script.estdates
    Array[File] roottotip = BactDate_script.rtt
  }
}

