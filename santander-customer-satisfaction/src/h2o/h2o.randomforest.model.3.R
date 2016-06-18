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

# H20 Random Forest 
h2o.randomForest.model3 <-
  h2o.randomForest(y = "TARGET", 
                   x = col, 
                   training_frame = train.hex,
                   ntree = 200, 
                   max_depth = 30,
                   stopping_rounds = 2,
                   stopping_tolerance = 1e-2,
                   score_each_iteration = TRUE,
                   seed = 3000000)

h2o.randomForest.model3

h2o.auc(h2o.randomForest.model3)
# 
head(h2o.varimp(h2o.randomForest.model3),20)

# AUC : 0.7802334


# Write Variables Importance
write.csv(h2o.varimp(h2o.randomForest.model3), "outputs/variables_importance/variable_importances-h2o.randomForest.model3.csv", row.names = F)


#test$TARGET <- -1
#test.hex <- as.h2o(test, destination_frame = "test.hex")

# Predicts

h2o.randomForest.model3.pred = h2o.predict(object = h2o.randomForest.model3, newdata = test.hex)
h2o.randomForest.model3.pred
class(h2o.randomForest.model3.pred)


# Transform H20Frame to DataFrame
h2o.randomForest.model3.pred.df <-as.data.frame(h2o.predict(object = h2o.randomForest.model3, newdata = test.hex))
h2o.randomForest.model3.pred.df
class(h2o.randomForest.model3.pred.df)

#pred<-exp(h2o.glm.model1.pred)

h2o.auc(h2o.randomForest.model3)

# Add Test ID for the predictions
test.id <- test$ID
#test$TARGET <- -1

submission <- data.frame(ID=test.id, TARGET=h2o.randomForest.model3.pred.df)
cat("saving the submission file\n")
write.csv(submission, "outputs/predictions/h2o.randomForest.model3.pred.df.csv", row.names = F)

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