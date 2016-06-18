### santander-customer-satisfaction

https://www.kaggle.com/c/santander-customer-satisfaction<BR>

### Dataset


### ML Algorithms

### Gradient Boosting Machine
A Gradient Boosting Machine (GBM) is an ensemble of tree models (either regression or classification). Both are forward-learning ensemble methods that obtain predictive results through gradually improved estimates. Boosting is a flexible nonlinear regression procedure that helps improve the accuracy of trees. By sequentially applying weak classification algorithms to incrementally changing data, a series of decision trees are created that produce an ensemble of weak prediction models. [1]

GBM is the most accurate general purpose algorithm. It can be used for analysis on numerous types of models and will always present relatively accurate results. Additionally, Gradient Boosting Machines are extremely robust, meaning that the user does not have to impute values or scale data (they can disregard distribution). This makes GBM the go-to choice for many users, as little tweaking is required in order to get accurate results. [1]

### Load data

Script: https://github.com/caiomsouza/kaggle-competitions/blob/master/santander-customer-satisfaction/src/utils/load_datasets.R

load_datasets.R

```
rm(list = ls())
setwd("~/git/github.com/kaggle-competitions/santander-customer-satisfaction")
path <- setwd("~/git/github.com/kaggle-competitions/santander-customer-satisfaction")

train.dataset.path <- "~/git/github.com/kaggle-competitions/santander-customer-satisfaction/dat/train.csv"
test.dataset.path <- "~/git/github.com/kaggle-competitions/santander-customer-satisfaction/dat/test.csv"

train <- read.csv(train.dataset.path)
cat("Train dataset loaded")
cat("at ")
cat(train.dataset.path)
test  <- read.csv(test.dataset.path)
cat("Test dataset loaded")
cat("at ")
cat(test.dataset.path)

#head(train,5)
#head(test,5)
#nrow(train)
#nrow(test)
#olnames(train)
#olnames(test)
#summary(train)
#summary(test)

```

### Data preparation




### References
1. H2o.ai - Gradient Boosting Machine. Avaiable at: http://www.h2o.ai/verticals/algos/gbm/
