# Caio Fernandes Moreno

rm(list = ls())
setwd("~/git/github.com/kaggle-competitions/santander-customer-satisfaction")
path <- setwd("~/git/github.com/kaggle-competitions/santander-customer-satisfaction")

train.dataset.path <- "~/git/github.com/kaggle-competitions/santander-customer-satisfaction/dat/train.csv"
test.dataset.path <- "~/git/github.com/kaggle-competitions/santander-customer-satisfaction/dat/test.csv"

train <- read.csv(train.dataset.path)
test  <- read.csv(test.dataset.path)

head(train,5)
head(test,5)
nrow(train)
nrow(test)
colnames(train)
colnames(test)



# h2o.init(Xmx="10g") will start up the H2O KV store with 10GB of RAM
#h2o.init(ip = "localhost", port = 54321, startH2O = TRUE)
#h20.init(Xmx="6g")
h2o.init(ip = "localhost", port = 54321, startH2O = TRUE, max_mem_size="6g", min_mem_size = "6g")

#h2o.init
#h20.shutdown()

# Demo to Test H20
#demo(h2o,glm)

train$TARGET <- as.factor(train$TARGET)
train.hex <- as.h2o(train, destination_frame = "train.hex")
test.hex <- as.h2o(test, destination_frame = "test.hex")

class(train.hex)
summary(train.hex)
col <- colnames(train)[-372]

# H20 GLM
model1 <- h2o.glm(y = "TARGET", x = col, training_frame = train.hex,
        family = "binomial", nfolds = 0, alpha = 0.5, lambda_search = FALSE)
# AUC = 0.8027083
# AIC:  22219.82
# Gini:  0.6054167

# Description: 10-fold cross-validation on training data (nfolds = 10)
model2 <- h2o.glm(y = "TARGET", x = col, training_frame = train.hex,
        family = "binomial", nfolds = 10, alpha = 0.5, lambda_search = FALSE)

summary(model2)
h2o.auc(model2)
head(h2o.varimp(model2),30)

# Best 30 variables in the Model 
best30variable <- head(h2o.varimp(model2),30)
nrow(best30variable)
best30variable

h2o.glm(y = "TARGET", x = col, training_frame = train.hex,
        family = "gaussian", nfolds = 0, alpha = 0.1, lambda_search = FALSE)

h2o.glm(y = "TARGET", x = col, training_frame = train.hex,
        family = "gaussian", nfolds = 0, alpha = 0.5, lambda_search = FALSE)

h20.glm.model3 <- h2o.glm(y = "TARGET", x = col, training_frame = train.hex, family="binomial", standardize=TRUE,
                 lambda_search=TRUE)

summary(h20.glm.model3)
h2o.auc(h20.glm.model3)

h20.glm.model4 <- h2o.glm(y = "TARGET", x = col, training_frame = train.hex, family="binomial", 
                          nfolds = 10, alpha = 0.5, standardize=TRUE,
                          lambda_search=FALSE)

summary(h20.glm.model4)
h2o.auc(h20.glm.model4)

h20.glm.model5 <- h2o.glm(y = "TARGET", x = col, training_frame = train.hex, family="binomial", 
                          alpha = 0.5, standardize=TRUE,
                          lambda_search=TRUE)

summary(h20.glm.model5)
h2o.auc(h20.glm.model5)



# H20 Random Forest 
rf.model1 <- h2o.randomForest(y = "TARGET", x = col, training_frame = train.hex, model_id, validation_frame = NULL,
                 checkpoint, mtries = -1, sample_rate = 0.632,
                 build_tree_one_node = FALSE, ntrees = 50, max_depth = 20,
                 min_rows = 1, nbins = 20, nbins_top_level, nbins_cats = 1024,
                 binomial_double_trees = FALSE, balance_classes = FALSE,
                 max_after_balance_size = 5, seed, offset_column = NULL,
                 weights_column = NULL, nfolds = 0, fold_column = NULL,
                 fold_assignment = c("AUTO", "Random", "Modulo"),
                 keep_cross_validation_predictions = FALSE, score_each_iteration = FALSE,
                 stopping_rounds = 0, stopping_metric = c("AUTO", "deviance", "logloss",
                                                          "MSE", "AUC", "r2", "misclassification"), stopping_tolerance = 0.001)

# H20 Random Forest 
h2o.randomForest.model1 <-
  h2o.randomForest(y = "TARGET", 
                   x = col, 
                   training_frame = train.hex,
                   ntree = 200, 
                   seed = 1000000,
                   nfolds = 5,
                   fold_assignment = c("Random"))
  
h2o.auc(h2o.randomForest.model1)
# 0.8108148
head(h2o.varimp(h2o.randomForest.model1),20)


# H20 Random Forest 
h2o.randomForest.model2 <-
  h2o.randomForest(y = "TARGET", 
                   x = col, 
                   training_frame = train.hex,
                   ntree = 200, 
                   seed = 1000000)

h2o.randomForest.model2

h2o.auc(h2o.randomForest.model2)
# 
head(h2o.varimp(h2o.randomForest.model2),20)

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



args(h2o.randomForest)


# Fit a deep learning regression model
h2o.deeplearning.model1 <- h2o.deeplearning(y = "TARGET", 
                                x = col, 
                                training_frame = train.hex)

h2o.deeplearning.model1
h2o.auc(h2o.deeplearning.model1)
# 0.7917043

# Fit a deep learning regression model
h2o.deeplearning.model2 <- h2o.deeplearning(y = "TARGET", 
                                            x = col, 
                                            training_frame = train.hex,
                                            activation = "TanhWithDropout")

h2o.deeplearning.model2
h2o.auc(h2o.deeplearning.model2)
# 0.7537723


# H20 GBM
h20.gbm.model1 <- h2o.gbm(y = "TARGET", x = col, training_frame = train.hex,
                  ntrees = 500, max_depth = 3, min_rows = 2)

h2o.auc(h20.gbm.model1)
# AUC 0.8769455
head(h2o.varimp(h20.gbm.model1),20)

print(h20.gbm.model1)






write.csv(h2o.varimp(h20.gbm.model1), "variable_importances.csv", row.names = F)

preds1 = h2o.predict(object = h20.gbm.model1, newdata = test.hex)

preds2 <-as.data.frame(h2o.predict(object = h20.gbm.model1, newdata = test.hex))
head(preds2)

pred<-exp(pred)

pred<-as.data.frame(h2o.predict(gbm, h2o_test))
pred<-exp(pred)

preds <- predict(clf, test)
head(preds,10)

submission <- data.frame(ID=test.id, TARGET=preds2)
cat("saving the submission file\n")
write.csv(submission, "submission_14abr16-06.csv", row.names = F)



h2o.auc(model1)

h2o.varimp(model1)

# H20 PCA
train.pca = h2o.prcomp(data = train.hex, standardize = TRUE)
print(train.pca)
summary(train.pca)

# H20 Predict
#prostate.hex = h2o.importFile(localH2O, path =
#                                "https://raw.github.com/0xdata/h2o/master/smalldata/logreg/prostate.csv", key = "prostate.hex")

#prostate.glm = h2o.glm(y = "CAPSULE", x =
#                         c("AGE","RACE","PSA","DCAPS"), data = prostate.hex,
#                       family = "binomial", nfolds = 10, alpha = 0.5)

#prostate.fit = h2o.predict(object = prostate.glm, newdata = prostate.hex)
#summary(prostate.fit)




test$TARGET <- -1
test <- sparse.model.matrix(TARGET ~ ., data = test)

preds <- predict(clf, test)
submission <- data.frame(ID=test.id, TARGET=preds)
cat("saving the submission file\n")
write.csv(submission, "submission_14abr16-06.csv", row.names = F)



### All done, shutdown H2O    
h2o.shutdown(prompt=FALSE)


# References
# https://github.com/h2oai/h2o-tutorials/blob/master/tutorials/gbm-randomforest/GBM_RandomForest_Example.R
# https://github.com/h2oai/h2o-world-2014-training/blob/master/tutorials/supervised/regression/regression.R.md
# http://docs.h2o.ai/h2o/latest-stable/h2o-docs/index.html
# http://www.r-bloggers.com/things-to-try-after-user-part-1-deep-learning-with-h2o/
# https://www.kaggle.com/aditya23/santander-customer-satisfaction/important-features-only/code
# http://h2o-release.s3.amazonaws.com/h2o/rel-lambert/5/docs-website/Ruser/rtutorial.html