# Specify the base R image 
FROM rocker/r-base

# Set the working directory inside the container 
WORKDIR /app 

# Copy your R script into the container at the working directory 
COPY BactDating.R /app/BactDating.R 

# Run the R script when the container starts 
CMD ["Rscript", "/app/BactDating.R"]
