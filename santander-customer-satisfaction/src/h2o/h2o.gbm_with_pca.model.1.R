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



# H20 PCA
predictors = c(1:371)
resp = 372

train.hex <- train.hex[,-resp]

pca_model1 <- h2o.prcomp(train.hex, k=60)

pca_model2 <- h2o.prcomp(train.hex, k=60,  transform = "STANDARDIZE")
pca_model2
#plot(pca_model@model$sdev)
print(pca_model2)
summary(pca_model2)


features_pca <- h2o.predict(pca_model2, train.hex, num_pc=60)
summary(features_pca)

ae_model <- h2o.deeplearning(x=predictors,
                             #y=42, #ignored (pick any non-constant predictor)
                             training_frame = train.hex,
                             activation="Tanh",
                             autoencoder=T,
                             hidden=c(100,50,100),
                             epochs=1,
                             ignore_const_cols = F)

features_ae <- h2o.deepfeatures(training_frame = train.hex, ae_model, layer=2)
summary(features_ae)


#train.pca <- h2o.prcomp(training_frame = train.hex, k = 10, transform = "STANDARDIZE")
#print(train.pca)
#summary(train.pca)
# 
#plot(train.pca@model$sdev)


# H2o GBM
h2o.gbm.model1 <- h2o.gbm(y = "TARGET", x = col, training_frame = train.hex,
                          ntrees = 500, max_depth = 3, min_rows = 2)

h2o.auc(h2o.gbm.model1)
# AUC 0.8766553
head(h2o.varimp(h2o.gbm.model1),20)

h2o.logloss(h2o.gbm.model1)
h2o.confusionMatrix(h2o.gbm.model1)

#test$TARGET <- -1
#test.hex <- as.h2o(test, destination_frame = "test.hex")

# Predicts

h2o.gbm.model1.pred = h2o.predict(object = h2o.gbm.model1, newdata = test.hex)
h2o.gbm.model1.pred
class(h2o.gbm.model1.pred)


# Transform H20Frame to DataFrame
h2o.gbm.model1.pred.df <-as.data.frame(h2o.predict(object = h2o.gbm.model1, newdata = test.hex))
h2o.gbm.model1.pred.df
class(h2o.gbm.model1.pred.df)

#pred<-exp(h2o.glm.model1.pred)

h2o.auc(h2o.gbm.model1)

#h2o.auc(h2o.deeplearning.model1.pred)

# Add Test ID for the predictions
test.id <- test$ID
#test$TARGET <- -1

submission <- data.frame(ID=test.id, TARGET=h2o.gbm.model1.pred.df)
cat("saving the submission file\n")
write.csv(submission, "outputs/predictions/h2o.gbm.model1.pred.df.csv", row.names = F)

# Find a way to create the submission file correctly to submit to Kaggle

### All done, shutdown H2O    
h2o.shutdown(prompt=FALSE)


# References
# https://h2o.gitbooks.io/h2o-training-day/content/hands-on_training/dimensionality_reduction.html
# https://github.com/h2oai/h2o-tutorials/blob/master/tutorials/gbm-randomforest/GBM_RandomForest_Example.R
# https://github.com/h2oai/h2o-world-2014-training/blob/master/tutorials/supervised/regression/regression.R.md
# http://docs.h2o.ai/h2o/latest-stable/h2o-docs/index.html
# http://www.r-bloggers.com/things-to-try-after-user-part-1-deep-learning-with-h2o/
# https://www.kaggle.com/aditya23/santander-customer-satisfaction/important-features-only/code
# http://h2o-release.s3.amazonaws.com/h2o/rel-lambert/5/docs-website/Ruser/rtutorial.html