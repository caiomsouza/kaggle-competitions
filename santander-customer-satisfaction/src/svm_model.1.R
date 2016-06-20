

#http://rischanlab.github.io/SVM.html

# Caio Fernandes Moreno

rm(list = ls())
setwd("~/git/github.com/kaggle-competitions/santander-customer-satisfaction")

# Script to load the Train and Test Dataset
source("src/utils/load_datasets.R")

# Explore Dataset
head(train,5)
head(test,5)
nrow(train)
nrow(test)
colnames(train)
colnames(test)

library(e1071)

##### Removing IDs
train$ID <- NULL
test.id <- test$ID
test$ID <- NULL

svm.model <- svm(TARGET ~ ., data = train, cost = 100, gamma = 1)

summary(svm.model)

# make the prediction (the dependent variable, Type, has column number 10)

svm.pred <- predict(svm.model, testset[,-10])

table(pred = svm.pred, true = testset[,10])



y = "TARGET"
x <- colnames(train)[-372]

model <- svm(y ~ . , train)

predictedY <- predict(model, data)



library("gmum.r")
## Not run: 
# train SVM from data in x and labels in y
svm <- SVM(x, y, core="libsvm", kernel="linear", C=1)

# train SVM using a dataset with both data and lables and a formula pointing to labels
formula <- target ~ .
svm <- SVM(formula, data, core="svmlight", kernel="rbf", gamma=1e3)

# train a model with 2eSVM algorithm
data(svm_breast_cancer_dataset)
ds <- svm.breastcancer.dataset
svm.2e <- SVM(x=ds[,-1], y=ds[,1], core="libsvm", kernel="linear", prep = "2e", C=10);
# more at \url{http://r.gmum.net/samples/svm.2e.html}

# train SVM on a multiclass data set
data(iris)
# with "one vs rest" strategy
svm.ova <- SVM(Species ~ ., data=iris, class.type="one.versus.all", verbosity=0)
# or with "one vs one" strategy
svm.ovo <- SVM(x=iris[,1:4], y=iris[,5], class.type="one.versus.one", verbosity=0)

# we can use svmlights sample weighting feature, suppose we have weights vector
# with a weight for every sample in the traning data
weighted.svm <- SVM(formula=y~., data=df, core="svmlight", kernel="rbf", C=1.0,
                    gamma=0.5, example.weights=weights)

# svmlight alows us to determine missing labels from a dataset
# suppose we have a labels y with missing labels marked as zeros
svm.transduction <- SVM(x, y, transductive.learning=TRUE, core="svmlight")

# for more in-depth examples visit \url{http://r.gmum.net/getting_started.html}

## End(Not run)