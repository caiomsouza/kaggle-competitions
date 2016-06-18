# http://learn.h2o.ai/content/tutorials/ensembles-stacking/index.html

# To install H2o in R see the file install_h2o_r.R

# Clean everything in R
gc()
rm(list = ls())

# Script to start H2O Server
source("src/h2o/setup/start_h2o_server.R")

# Script to load the Train and Test Dataset
source("src/utils/load_datasets.R")

# Script to clean the Train and Test Dataset
source("src/utils/clean_datasets.R")

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


h2o.ensemble.model1 <- h2o.ensemble(y = "TARGET", x = col, training_frame = train.hex, 
                    family = "binomial", 
                    learner = learner, 
                    metalearner = metalearner,
                    cvControl = list(V = 5))

print(h2o.ensemble.model1)
h2o.ensemble.model1

# There is an error in the code below... how can I add a column in h2o dataset.
test$TARGET <- -1
test.hex$TARGET <- NULL
# Evaluate performance on a test set
perf <- h2o.ensemble_performance(h2o.ensemble.model1, newdata = test.hex)
perf


pred <- predict(h2o.ensemble.model1, test.hex)
pred
pred$pred
pred$basepred

predictions <- as.data.frame(pred$pred)[,3]  #third column is P(Y==1)
predictions
labels <- as.data.frame(train$TARGET)[,1]

labels

perf$ensemble

as.data.frame(pred$pred)[,4]

h2o.auc(perf$ensemble)


#install.packages("cvAUC")
library(cvAUC)
cvAUC::AUC(predictions = predictions, labels = labels)

L <- length(learner)
auc <- sapply(seq(L), function(l) cvAUC::AUC(predictions = as.data.frame(pred$basepred)[,l], labels = labels)) 
data.frame(learner, auc)


# http://www.rdocumentation.org/packages/h2o/functions/h2o.glm
# http://s3.amazonaws.com/h2o-release/h2o/master/1732/docs-website/datascience/glm.html
# https://cran.r-project.org/web/packages/h2o/h2o.pdf

# https://github.com/h2oai/h2o-3/tree/master/h2o-r/ensemble



