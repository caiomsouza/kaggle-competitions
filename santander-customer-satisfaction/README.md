### santander-customer-satisfaction

https://www.kaggle.com/c/santander-customer-satisfaction<BR>

### Dataset


### ML Algorithms

### Gradient Boosting Machine
A Gradient Boosting Machine (GBM) is an ensemble of tree models (either regression or classification). Both are forward-learning ensemble methods that obtain predictive results through gradually improved estimates. Boosting is a flexible nonlinear regression procedure that helps improve the accuracy of trees. By sequentially applying weak classification algorithms to incrementally changing data, a series of decision trees are created that produce an ensemble of weak prediction models. [1]

GBM is the most accurate general purpose algorithm. It can be used for analysis on numerous types of models and will always present relatively accurate results. Additionally, Gradient Boosting Machines are extremely robust, meaning that the user does not have to impute values or scale data (they can disregard distribution). This makes GBM the go-to choice for many users, as little tweaking is required in order to get accurate results. [1]

### Load data
../src/utils/load_datasets.R

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
Code:<BR> https://github.com/caiomsouza/kaggle-competitions/blob/master/santander-customer-satisfaction/src/utils/load_datasets.R<BR>

### Data preparation

The script below will do data preparation for the Santander Customer Satisfaction dataset.
* Extracting TARGET
* 0 count per line
* Removing constant features
* Removing identical features


../src/utils/clean_datasets.R

```
##### Removing IDs
#train$ID <- NULL
#test.id <- test$ID
#test$ID <- NULL


##### Extracting TARGET
train.y <- train$TARGET
train$TARGET <- NULL

##### 0 count per line
count0 <- function(x) {
  return( sum(x == 0) )
}
train$n0 <- apply(train, 1, FUN=count0)
test$n0 <- apply(test, 1, FUN=count0)

##### Removing constant features
cat("\n## Removing constant features.\n")
for (f in names(train)) {
  if (length(unique(train[[f]])) == 1) {
    cat("-", f, "\n")
    train[[f]] <- NULL
    test[[f]] <- NULL
  }
}

##### Removing identical features
cat("\n## Removing identical features.\n")
features_pair <- combn(names(train), 2, simplify = F)
toRemove <- c()
for(pair in features_pair) {
  f1 <- pair[1]
  f2 <- pair[2]

  if (!(f1 %in% toRemove) & !(f2 %in% toRemove)) {
    if (all(train[[f1]] == train[[f2]])) {
      cat("-", f2, "\n")
      toRemove <- c(toRemove, f2)
    }
  }
}

feature.names <- setdiff(names(train), toRemove)

train <- train[, feature.names]
test <- test[, feature.names]

train$TARGET <- train.y
```

Code: <BR>
https://github.com/caiomsouza/kaggle-competitions/blob/master/santander-customer-satisfaction/src/utils/clean_datasets.R <BR>

Data preparation output:<BR>

```
## Removing constant features.
- ind_var2_0
- ind_var2
- ind_var27_0
- ind_var28_0
- ind_var28
- ind_var27
- ind_var41
- ind_var46_0
- ind_var46
- num_var27_0
- num_var28_0
- num_var28
- num_var27
- num_var41
- num_var46_0
- num_var46
- saldo_var28
- saldo_var27
- saldo_var41
- saldo_var46
- imp_amort_var18_hace3
- imp_amort_var34_hace3
- imp_reemb_var13_hace3
- imp_reemb_var33_hace3
- imp_trasp_var17_out_hace3
- imp_trasp_var33_out_hace3
- num_var2_0_ult1
- num_var2_ult1
- num_reemb_var13_hace3
- num_reemb_var33_hace3
- num_trasp_var17_out_hace3
- num_trasp_var33_out_hace3
- saldo_var2_ult1
- saldo_medio_var13_medio_hace3

## Removing identical features.
- ind_var29_0
- ind_var29
- ind_var13_medio
- ind_var18
- ind_var26
- ind_var25
- ind_var32
- ind_var34
- ind_var37
- ind_var39
- num_var29_0
- num_var29
- num_var13_medio
- num_var18
- num_var26
- num_var25
- num_var32
- num_var34
- num_var37
- num_var39
- saldo_var29
- saldo_medio_var13_medio_ult1
- delta_num_reemb_var13_1y3
- delta_num_reemb_var17_1y3
- delta_num_reemb_var33_1y3
- delta_num_trasp_var17_in_1y3
- delta_num_trasp_var17_out_1y3
- delta_num_trasp_var33_in_1y3
- delta_num_trasp_var33_out_1y3

```

### References
1. H2o.ai - Gradient Boosting Machine. Avaiable at: http://www.h2o.ai/verticals/algos/gbm/
