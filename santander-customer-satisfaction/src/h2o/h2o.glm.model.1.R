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

# H2o GLM
h2o.glm.model1 <- h2o.glm(y = "TARGET", x = col, training_frame = train.hex,
                  family = "binomial", nfolds = 0, alpha = 0.5, lambda_search = FALSE)
h2o.auc(h2o.glm.model1)
summary(h2o.glm.model1)
h2o.glm.model1
# AUC = 0.8027083
# AIC:  22219.82
# Gini:  0.6054167

# Write Variables Importance
write.csv(h2o.varimp(h2o.glm.model1), "outputs/variables_importance/variable_importances-h2o.glm.model1.csv", row.names = F)

#test$TARGET <- -1
#test.hex <- as.h2o(test, destination_frame = "test.hex")

# Predicts

h2o.glm.model1.pred = h2o.predict(object = h2o.glm.model1, newdata = test.hex)
h2o.glm.model1.pred
class(h2o.glm.model1.pred)

# Transform H20Frame to DataFrame
h2o.glm.model1.pred.df <-as.data.frame(h2o.predict(object = h2o.glm.model1, newdata = test.hex))
h2o.glm.model1.pred.df
class(h2o.glm.model1.pred.df)

#pred<-exp(h2o.glm.model1.pred)

# Add Test ID for the predictions
test.id <- test$ID
#test$TARGET <- -1

submission <- data.frame(ID=test.id, TARGET=h2o.glm.model1.pred.df)
cat("saving the submission file\n")
write.csv(submission, "outputs/predictions/h2o.glm.model1.pred.df.csv", row.names = F)

# Find a way to create the submission file correctly to submit to Kaggle

# Script to stop H2O Server
source("src/h2o/setup/stop_h2o_server.R")