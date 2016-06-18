# Caio Fernandes Moreno

rm(list = ls())
setwd("~/git/github.com/kaggle-competitions/santander-customer-satisfaction")

# Script to load the Train and Test Dataset
source("src/utils/load_datasets.R")

# Script to start H2O Server
source("src/h2o/setup/start_h2o_server.R")

# H2o R Package Documentation
# ??h2o

# Explore Dataset
head(train,5)
head(test,5)
nrow(train)
nrow(test)
colnames(train)
colnames(test)

train$TARGET <- as.factor(train$TARGET)
train.hex <- as.h2o(train, destination_frame = "train.hex")
test.hex <- as.h2o(test, destination_frame = "test.hex")

class(train.hex)
summary(train.hex)
col <- colnames(train)[-372]


# Fit a deep learning regression model
h2o.deeplearning.model1 <- h2o.deeplearning(y = "TARGET", 
                                            x = col, 
                                            training_frame = train.hex)

h2o.deeplearning.model1
h2o.auc(h2o.deeplearning.model1)
# 0.8018106

#test$TARGET <- -1
#test.hex <- as.h2o(test, destination_frame = "test.hex")

# Predicts

h2o.deeplearning.model1.pred = h2o.predict(object = h2o.deeplearning.model1, newdata = test.hex)
h2o.deeplearning.model1.pred
class(h2o.deeplearning.model1.pred)


# Transform H20Frame to DataFrame
h2o.deeplearning.model1.pred.df <-as.data.frame(h2o.predict(object = h2o.deeplearning.model1, newdata = test.hex))
h2o.deeplearning.model1.pred.df
class(h2o.deeplearning.model1.pred.df)

#pred<-exp(h2o.glm.model1.pred)

h2o.auc(h2o.deeplearning.model1)
# AUC: # 0.8018106

#h2o.auc(h2o.deeplearning.model1.pred)

# Add Test ID for the predictions
test.id <- test$ID
#test$TARGET <- -1

submission <- data.frame(ID=test.id, TARGET=h2o.deeplearning.model1.pred.df)
cat("saving the submission file\n")
write.csv(submission, "outputs/predictions/h2o.deeplearning.model1.pred.df.csv", row.names = F)

# Find a way to create the submission file correctly to submit to Kaggle

### All done, shutdown H2O    
h2o.shutdown(prompt=FALSE)


# References
# https://github.com/h2oai/h2o-tutorials/blob/master/tutorials/gbm-randomforest/GBM_RandomForest_Example.R
# https://github.com/h2oai/h2o-world-2014-training/blob/master/tutorials/supervised/regression/regression.R.md
# http://docs.h2o.ai/h2o/latest-stable/h2o-docs/index.html
# http://www.r-bloggers.com/things-to-try-after-user-part-1-deep-learning-with-h2o/
# https://www.kaggle.com/aditya23/santander-customer-satisfaction/important-features-only/code
# http://h2o-release.s3.amazonaws.com/h2o/rel-lambert/5/docs-website/Ruser/rtutorial.html