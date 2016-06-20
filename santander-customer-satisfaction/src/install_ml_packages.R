# Machine Learning Packages
# Caio github.com/caiomsouza


# https://scottishsnow.wordpress.com/software/

# Install R in Ubuntu
# sudo apt-get update
# sudo apt-get install r-base

# Install RStudio in Ubuntu
# wget http://download1.rstudio.org/rstudio-0.98.1062-amd64.deb
# sudo dpkg -i *.deb
# rm *.deb

# Run Install R Script
# sudo Rscript install_ml_packages.R



install.packages("caret", repos='http://cran.rstudio.com/', dependencies = TRUE)
install.packages("sas7bdat", repos='http://cran.rstudio.com/', dependencies = TRUE)
install.packages("caret", repos='http://cran.rstudio.com/', dependencies = TRUE)
install.packages("gbm", repos='http://cran.rstudio.com/', dependencies = TRUE)

library(sas7bdat)
library(caret)
library(gbm)

cat("Installed all packages.")
