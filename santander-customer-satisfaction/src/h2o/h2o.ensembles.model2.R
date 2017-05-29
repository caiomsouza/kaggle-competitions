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

nrow(train)
nrow(test)

head(train, 3)
summary(train)
head(test, 3)

head(train)
colnames(train)
head(test)

train$TARGET <- as.factor(train$TARGET)
train.hex <- as.h2o(train, destination_frame = "train.hex")
#test$TARGET <- as.factor(test$TARGET)
test.hex <- as.h2o(test, destination_frame = "test.hex")

# Add Target 
test.hex$TARGET <- -1
test.hex$TARGET <- as.factor(test$TARGET)

class(train.hex)
summary(train.hex)
col <- colnames(train)[-372]

class(test.hex)
summary(test.hex)



# Specify the base learner library & the metalearner
learner <- c("h2o.glm.wrapper", "h2o.randomForest.wrapper", 
             "h2o.gbm.wrapper", "h2o.deeplearning.wrapper")
metalearner <- "h2o.glm.wrapper"
family <- "binomial"


# Train the ensemble using 5-fold CV to generate level-one data
# More CV folds will take longer to train, but should increase performance
fit <- h2o.ensemble(y = "TARGET", 
                    x = col, 
                    training_frame = train.hex,
                    family = family, 
                    learner = learner, 
                    metalearner = metalearner,
                    cvControl = list(V = 5, shuffle = TRUE))


# Evaluate performance on a test set
#perf <- h2o.ensemble_performance(fit, newdata = test.hex)
perf <- h2o.ensemble_performance(fit, newdata = train.hex)
perf

# Ate aqui funcionou 

y = "TARGET"

# If desired, you can generate predictions on the test set
# This is useful if you need to calculate custom performance metrics in R (not provided by H2O)
pp <- predict(fit, test.hex)
predictions <- as.data.frame(pp$pred)[,3]  #third column, p1 is P(Y==1)
labels <- as.data.frame(test.hex[,y])[,1]
h2o.auc(perf$ensemble)





# Now try metalearning with non-negative weights to see if that helps
h2o.glm_nn <- function(..., non_negative = TRUE) {
  h2o.glm.wrapper(..., non_negative = non_negative)
}
metalearner <- "h2o.glm_nn"
fit <- h2o.metalearn(fit, metalearner)
perf <- h2o.ensemble_performance(fit, newdata = test.hex)
# Re-test ensemble AUC
h2o.auc(perf$ensemble)
# [1] 0.686091   # very slight improvement...


# Try a DL metalearner
metalearner <- "h2o.deeplearning.wrapper"
fit <- h2o.metalearn(fit, metalearner)
perf <- h2o.ensemble_performance(fit, newdata = test)
# Re-test ensemble AUC
h2o.auc(perf$ensemble)
# [1] 0.6856208  #not as good as a linear metalearner



# Now let's try again with a more extensive set of base learners
# Here is an example of how to generate a custom learner wrappers:
h2o.glm.1 <- function(..., alpha = 0.0) h2o.glm.wrapper(..., alpha = alpha)
h2o.glm.2 <- function(..., alpha = 0.5) h2o.glm.wrapper(..., alpha = alpha)
h2o.glm.3 <- function(..., alpha = 1.0) h2o.glm.wrapper(..., alpha = alpha)
h2o.randomForest.1 <- function(..., ntrees = 200, nbins = 50, seed = 1) h2o.randomForest.wrapper(..., ntrees = ntrees, nbins = nbins, seed = seed)
h2o.randomForest.2 <- function(..., ntrees = 200, sample_rate = 0.75, seed = 1) h2o.randomForest.wrapper(..., ntrees = ntrees, sample_rate = sample_rate, seed = seed)
h2o.randomForest.3 <- function(..., ntrees = 200, sample_rate = 0.85, seed = 1) h2o.randomForest.wrapper(..., ntrees = ntrees, sample_rate = sample_rate, seed = seed)
h2o.gbm.1 <- function(..., ntrees = 100, nbins = 100, seed = 1) h2o.gbm.wrapper(..., ntrees = ntrees, nbins = nbins, seed = seed)
h2o.gbm.2 <- function(..., ntrees = 200, nbins = 50, seed = 1) h2o.gbm.wrapper(..., ntrees = ntrees, nbins = nbins, seed = seed)
h2o.gbm.3 <- function(..., ntrees = 100, max_depth = 10, seed = 1) h2o.gbm.wrapper(..., ntrees = ntrees, max_depth = max_depth, seed = seed)
h2o.gbm.4 <- function(..., ntrees = 100, col_sample_rate = 0.8, seed = 1) h2o.gbm.wrapper(..., ntrees = ntrees, col_sample_rate = col_sample_rate, seed = seed)
h2o.gbm.5 <- function(..., ntrees = 200, col_sample_rate = 0.8, seed = 1) h2o.gbm.wrapper(..., ntrees = ntrees, col_sample_rate = col_sample_rate, seed = seed)
h2o.gbm.6 <- function(..., ntrees = 200, col_sample_rate = 0.7, seed = 1) h2o.gbm.wrapper(..., ntrees = ntrees, col_sample_rate = col_sample_rate, seed = seed)
h2o.deeplearning.1 <- function(..., hidden = c(500,500), activation = "Rectifier", seed = 1)  h2o.deeplearning.wrapper(..., hidden = hidden, activation = activation, seed = seed)
h2o.deeplearning.2 <- function(..., hidden = c(200,200,200), activation = "Tanh", seed = 1)  h2o.deeplearning.wrapper(..., hidden = hidden, activation = activation, seed = seed)
h2o.deeplearning.3 <- function(..., hidden = c(500,500), activation = "RectifierWithDropout", seed = 1)  h2o.deeplearning.wrapper(..., hidden = hidden, activation = activation, seed = seed)


learner <- c("h2o.glm.1", "h2o.glm.2", "h2o.glm.3",
             "h2o.randomForest.1", "h2o.randomForest.2", "h2o.randomForest.3",
             "h2o.gbm.1", "h2o.gbm.2", "h2o.gbm.3", "h2o.gbm.4", "h2o.gbm.5", "h2o.gbm.6",
             "h2o.deeplearning.1", "h2o.deeplearning.2", "h2o.deeplearning.3")
metalearner <- "h2o.glm_nn"
family <- "binomial"

# Train the ensemble using 5-fold CV to generate level-one data
# More CV folds will take longer to train, but should increase performance
fit <- h2o.ensemble(x = x, y = y, 
                    training_frame = train,
                    family = family, 
                    learner = learner, 
                    metalearner = metalearner,
                    cvControl = list(V = 5, shuffle = TRUE))


# Evaluate performance on a test set
perf <- h2o.ensemble_performance(fit, newdata = test)
perf


# To print the results for a particular metric, like MSE, do the following:
print(perf, metric = "MSE")

# To print the results for a particular metric, like AUC, do the following:
print(perf, metric = "AUC")













# aqui coisa nova 




learner <- c("h2o.glm.wrapper", "h2o.randomForest.wrapper", 
             "h2o.gbm.wrapper", "h2o.deeplearning.wrapper")
metalearner <- "h2o.glm.wrapper"


h2o.ensemble.model1 <- h2o.ensemble(y = "TARGET", x = col, training_frame = train.hex, 
                    family = "binomial", 
                    learner = learner, 
                    metalearner = metalearner,
                    cvControl = list(V = 5))

print(h2o.ensemble.model1)
h2o.auc(h2o.ensemble.model1)


pred <- predict(h2o.ensemble.model1, test.hex)
pred
pred$pred
pred$basepred

predictions <- as.data.frame(pred$pred)[,3]  #third column is P(Y==1)
predictions
labels <- as.data.frame(train$TARGET)[,1]

labels

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



