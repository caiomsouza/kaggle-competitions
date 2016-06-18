# http://learn.h2o.ai/content/tutorials/ensembles-stacking/index.html

# To install H2o in R see the file install_h2o_r.R

library(h2oEnsemble)  # This will load the `h2o` R package as well
#h2o.init(nthreads = -1)  # Start an H2O cluster with nthreads = num cores on your machine
h2o.init(nthreads = -1, ip = "localhost", port = 54321, startH2O = TRUE, max_mem_size="6g", min_mem_size = "6g")
h2o.removeAll() # Clean slate - just in case the cluster was already running

# Clean everything in R
gc()
rm(list = ls())

setwd("~/git/Bitbucket/ucm/TFM/kaggle/santander-customer-satisfaction")

train <- read.csv("dat/train.csv")
test  <- read.csv("dat/test.csv")

#train <- h2o.importFile(path = normalizePath("dat/train.csv"))
#test <- h2o.importFile(path = normalizePath("dat/test.csv"))

head(train, 3)
summary(train)
head(test, 3)

head(train)
colnames(train)
head(test)

train$TARGET <- as.factor(train$TARGET)
train.hex <- as.h2o(train, destination_frame = "train.hex")
test.hex <- as.h2o(test, destination_frame = "test.hex")



class(train.hex)
summary(train.hex)
col <- colnames(train)[-372]


learner <- c("h2o.glm.wrapper", "h2o.randomForest.wrapper", 
             "h2o.gbm.wrapper", "h2o.deeplearning.wrapper")
metalearner <- "h2o.glm.wrapper"


fit <- h2o.ensemble(y = "TARGET", x = col, training_frame = train.hex, 
                    family = "binomial", 
                    learner = learner, 
                    metalearner = metalearner,
                    cvControl = list(V = 5))

print(fit)
h2o.auc(fit)


pred <- predict(fit, test.hex)
pred
pred$pred
pred$basepred

predictions <- as.data.frame(pred$pred)[,3]  #third column is P(Y==1)
predictions
labels <- as.data.frame(train$TARGET)[,1]

labels



#install.packages("cvAUC")
library(cvAUC)
cvAUC::AUC(predictions = predictions, labels = labels)

L <- length(learner)
auc <- sapply(seq(L), function(l) cvAUC::AUC(predictions = as.data.frame(pred$basepred)[,l], labels = labels)) 
data.frame(learner, auc)


# http://www.rdocumentation.org/packages/h2o/functions/h2o.glm
# http://s3.amazonaws.com/h2o-release/h2o/master/1732/docs-website/datascience/glm.html
# https://cran.r-project.org/web/packages/h2o/h2o.pdf


