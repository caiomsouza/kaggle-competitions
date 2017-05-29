# Caio Fernandes Moreno

rm(list = ls())
setwd("~/git/github.com/kaggle-competitions/santander-customer-satisfaction")

# Script to load the Train and Test Dataset
source("src/utils/load_datasets.R")

summary(train)

# BoxCox
# load libraries
library(mlbench)
library(caret)
# calculate the pre-process parameters from the dataset
preprocessParams <- preProcess(train, method=c("BoxCox"))
# summarize transform parameters
print(preprocessParams)
# transform the dataset using the parameters
transformed <- predict(preprocessParams, train)
# summarize the transformed dataset (note pedigree and age)
summary(transformed)

# Set BoxCox Variables to train 
train <- transformed  

summary(train)

##### Removing IDs
train$ID <- NULL
test.id <- test$ID
test$ID <- NULL
tc <- test

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
cat("\n## Removing the constants features.\n")
for (f in names(train)) {
  if (length(unique(train[[f]])) == 1) {
    cat(f, "is constant in train. We delete it.\n")
    train[[f]] <- NULL
    test[[f]] <- NULL
  }
}

##### Removing identical features
features_pair <- combn(names(train), 2, simplify = F)
toRemove <- c()
for(pair in features_pair) {
  f1 <- pair[1]
  f2 <- pair[2]
  
  if (!(f1 %in% toRemove) & !(f2 %in% toRemove)) {
    if (all(train[[f1]] == train[[f2]])) {
      cat(f1, "and", f2, "are equals.\n")
      toRemove <- c(toRemove, f2)
    }
  }
}

feature.names <- setdiff(names(train), toRemove)

train$var38 <- log(train$var38)
test$var38 <- log(test$var38)

train <- train[, feature.names]
test <- test[, feature.names]
tc <- test

#---limit vars in test based on min and max vals of train
print('Setting min-max lims on test data')
for(f in colnames(train)){
  lim <- min(train[,f])
  test[test[,f]<lim,f] <- lim
  
  lim <- max(train[,f])
  test[test[,f]>lim,f] <- lim  
}
#---

train$TARGET <- train.y

head(train)
nrow(train)
colnames(train)

## Add 


library(ggplot2) # Data visualization
library(readr) # CSV file I/O, e.g. the read_csv function

# Input data files are available in the "../input/" directory.
# For example, running this (by clicking run or pressing Shift+Enter) will list the files in the input directory

system("ls ../input")

# Any results you write to the current directory are saved as output.
library(xgboost)
library(Matrix)

set.seed(1234)


train <- sparse.model.matrix(TARGET ~ ., data = train)

dtrain <- xgb.DMatrix(data=train, label=train.y)
watchlist <- list(train=dtrain)

param <- list(  objective           = "binary:logistic", 
                booster             = "gbtree",
                eval_metric         = "auc",
                eta                 = 0.0202048,
                max_depth           = 5,
                subsample           = 0.6815,
                colsample_bytree    = 0.701
)

clf <- xgb.train(   params              = param, 
                    data                = dtrain, 
                    nrounds             = 560, 
                    print.every.n       = 10,
                    verbose             = 1,
                    watchlist           = watchlist,
                    maximize            = TRUE
)


#######actual variables

feature.names

test$TARGET <- -1

test <- sparse.model.matrix(TARGET ~ ., data = test)

preds <- predict(clf, test)
pred <-predict(clf,train)
AUC<-function(actual,predicted)
{
  library(pROC)
  auc<-auc(as.numeric(actual),as.numeric(predicted))
  auc 
}
AUC(train.y,pred) ##AUC

# Generate submission file
submission <- data.frame(ID=test.id, TARGET=preds)
head(preds)
head(submission)

cat("saving the submission file\n")
write.csv(submission, "outputs/predictions/xgb.model.1.BoxCox.model.2016093-try-02.csv", row.names = F)

# Kaggle Position 1868
# Kaggle AUC: 0.825281

# With BoxCox
# Kaggle Position 4344
# Kaggle AUC: 0.700

# For xgb.model.1.BoxCox.model.2016093-try-02.csv
# Kaggle Position 4347
# Kaggle AUC: 0.698919

# https://www.analyticsvidhya.com/blog/2016/01/xgboost-algorithm-easy-steps/
importance_matrix <- xgb.importance(train, model = bst)
xgb.plot.importance(importance_matrix)




