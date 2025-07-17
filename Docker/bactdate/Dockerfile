# Start with the rocker image
FROM --platform=linux/amd64 rocker/r-ver:4.4

# Install cran packages
RUN R -e "install.packages('remotes', dependencies=TRUE, repos='http://cran.rstudio.com/')" 
RUN R -e "install.packages('dplyr', dependencies=TRUE, repos='http://cran.rstudio.com/')" 
RUN R -e "install.packages('ape', dependencies=TRUE, repos='http://cran.rstudio.com/')" 

# Install a BactDating from GitHub
RUN R -e "remotes::install_github('xavierdidelot/BactDating', dependencies=T)"

# Set the working directory inside the container 
WORKDIR /app 

# Copy your R script into the container at the working directory 
COPY BactDating.R /app/BactDating.R 

# Run the R script when the container starts 
CMD ["Rscript", "/app/BactDating.R"]