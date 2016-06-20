# Machine Learning Packages
# Caio github.com/caiomsouza


install.packages('caret', repos='http://cran.rstudio.com/', dependencies = TRUE)
install.packages("sas7bdat", repos='http://cran.rstudio.com/', dependencies = TRUE)
install.packages("caret", repos='http://cran.rstudio.com/', dependencies = TRUE)
install.packages("gbm", repos='http://cran.rstudio.com/', dependencies = TRUE)

library(sas7bdat)
library(caret)
library(gbm)

cat("Installed all packages.")
