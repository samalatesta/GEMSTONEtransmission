# Start with the rocker image
FROM --platform=linux/amd64 rocker/r-ver:4.4

# Install cran packages
RUN R -e "install.packages('remotes', dependencies=TRUE, repos='http://cran.rstudio.com/')" 
RUN R -e "install.packages('dplyr', dependencies=TRUE, repos='http://cran.rstudio.com/')" 
RUN R -e "install.packages('ape', dependencies=TRUE, repos='http://cran.rstudio.com/')" 

# Install a TransPhylo2 from GitHub
RUN R -e "remotes::install_github('DrJCarson/TransPhylo2', dependencies=T)"

# Set the working directory inside the container 
WORKDIR /app 

# Copy your R script into the container at the working directory 
COPY TransPhylo2.R /app/TransPhylo2.R 

# Run the R script when the container starts 
CMD ["Rscript", "/app/TransPhylo2.R"]