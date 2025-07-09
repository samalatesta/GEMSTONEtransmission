version 1.0

    

task beast {
  input {
    File     xml

  }


  command {
 
    beast ~{xml}
  }

  output {
    File        beast_log    = glob("*.log")[0]
    Array[File] trees        = glob("*.trees")
    File        beast_stdout = stdout()
  }

  runtime {
    docker: "tomkinsc/beast2-beagle-cuda"
  }
}

    workflow beast {
        meta {
                author: "Samantha Malatesta"
                email: "smalates@broadinstitute.org"
        }

        input {
            File xml

        }


       call beast {
               input:
                  xml = xml
                }       

        output {
    
        File        beast_log    = beast.beast_log
        Array[File] trees        = beast.trees
        String      beast_stdout = beast.beast_stdout

        }
    }