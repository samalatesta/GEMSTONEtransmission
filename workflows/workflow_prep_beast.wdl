version 1.0

    task combine_fasta {
        input {
            Array[File] fasta_files  # An array of FASTA files
    
        }

        command {
            cat ~{sep=" " fasta_files} > "combined.fasta"
        }

        output {
            File combined_fasta = "combined.fasta"
        }

        runtime {
            docker: 'ubuntu:latest'
        }

    }
task xmlR {
      input {
           File fasta
           Array[String] ids
           Array[String] dates
           Int? chain_length=100
}

command<<<
    R --no-save --args ~{fasta} ~{sep=" " ids} ~{sep=" " dates}<<Rscript
    args <- commandArgs(trailingOnly = TRUE)

            idsstart = 2
            idsend = ((length(args)-1)/2)+1
            ids=args[idsstart:idsend]
            datesstart = ((length(args)-1)/2)+2
            datesend= length(args)
            dates=args[datesstart:datesend]
            fasta = args[1]
            
          
            #make tip dates file
            write.table(data.frame(ids, dates), "tip_dates.txt", sep="\t", row.names =F, col.names=F)

            install.packages("beautier")
            library(beautier)

            #create mcmc
            mcmc = create_mcmc(chain_length = ~{chain_length})

            #create inference model
            inference_model <- create_inference_model(
            tipdates_filename = "tip_dates.txt", mcmc=mcmc)

            #create xml file
            create_beast2_input_file_from_model(
            inference_model=inference_model,
            input_filename = fasta,
            output_filename = "beast_input.xml"
            )
    Rscript
  >>>
 output {
            File xml = "beast_input.xml"
            
        }
runtime {
            docker: "r-base:latest"
       }

}



    workflow prep_beast {
        meta {
                author: "Samantha Malatesta"
                email: "smalates@broadinstitute.org"
        }

        input {
            Array[File] samples
            Array[String] ids
            Array[String] dates
            Int? chain_length

        }

        call combine_fasta {
                input:
                    fasta_files = samples
        }

        call xmlR {
               input:
                  fasta = combine_fasta.combined_fasta,
                  ids = ids,
                  dates = dates,
                  chain_length = chain_length
                }


        output {
    
        #File combined_fasts = combine_fasta.combined_fasta
        File xml = xmlR.xml
       

        }
    }

