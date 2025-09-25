version 1.0

task infer_tree {
input {
    File? dated_tree
    Array[String] ids
    Array[String] sample_dates
    String? max_date = "2025-01-01"
    Int? mcmc
    Int? w_shape
    Float? w_scale
  }
    command <<<

    cp ~{dated_tree} .

    declare -a bash_array=(~{sep=" " ids})
    printf "%s\n" "${bash_array[@]}" > ids.txt
    declare -a bash_array=(~{sep=" " sample_dates})
    printf "%s\n" "${bash_array[@]}" > dates.txt
      
        Rscript /app/TransPhylo2.R ~{dated_tree} \
           "~{max_date}" \
            ~{mcmc} \
            ~{w_shape} \
             ~{w_scale} \
             ~"ids.txt" \
             ~"dates.txt" \
             
    >>>
        output {
            File stdout = stdout()
            File rlog = "TransPhylo2.log"
            Array[File] results = glob("*_results.rda")
            
        }
  runtime {
    docker: "samalate/transphylo2:test" 
  }
}


# Define the workflow that uses the task
workflow TransPhylo2 {
  input {
    File? dated_tree
    Array[String] ids
    Array[String] sample_dates
    String? max_date = "2025-01-01"
    Int? mcmc
    Int? w_shape
    Float? w_scale
  }

  call infer_tree{
    input: sample_dates=sample_dates, ids=ids, dated_tree = dated_tree, max_date = max_date, mcmc=mcmc, w_shape=w_shape, w_scale=w_scale
  }

  output {
    Array[File] results = infer_tree.results
    File rLog = infer_tree.rlog
    File out = infer_tree.stdout

  }
}

