# Caio Fernandes Moreno

rm(list = ls())
setwd("~/git/github.com/kaggle-competitions/santander-customer-satisfaction")

# Script to start H2O Server
source("src/h2o/setup/start_h2o_server.R")

# Script to load the Train and Test Dataset
source("src/utils/load_datasets.R")

# Script to clean the Train and Test Dataset
source("src/utils/clean_datasets.R")

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
h2o.glm.model2 <- h2o.glm(y = "TARGET", x = col, training_frame = train.hex,
                          family = "binomial", nfolds = 0, alpha = 0.5, lambda_search = FALSE)
h2o.auc(h2o.glm.model2)
summary(h2o.glm.model2)
h2o.glm.model2
# AUC = 0.8025738

# Write Variables Importance
write.csv(h2o.varimp(h2o.glm.model2), "outputs/variables_importance/variable_importances-h2o.glm.model2.csv", row.names = F)

#test$TARGET <- -1
#test.hex <- as.h2o(test, destination_frame = "test.hex")

# Predicts

h2o.glm.model2.pred = h2o.predict(object = h2o.glm.model2, newdata = test.hex)
h2o.glm.model2.pred
class(h2o.glm.model2.pred)

# Transform H20Frame to DataFrame
h2o.glm.model2.pred.df <-as.data.frame(h2o.predict(object = h2o.glm.model2, newdata = test.hex))
h2o.glm.model2.pred.df
class(h2o.glm.model2.pred.df)

#pred<-exp(h2o.glm.model1.pred)

#test$ID

# Add Test ID for the predictions
test.id <- test$ID

submission <- data.frame(ID=test.id, TARGET=h2o.glm.model2.pred.df)
cat("saving the submission file\n")
write.csv(submission, "outputs/predictions/h2o.glm.model1.pred.df.csv", row.names = F)


# Script to stop H2O Server
source("src/h2o/setup/stop_h2o_server.R")



























# Validado ate aqui.


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



# Script to stop H2O Server
source("src/h2o/setup/stop_h2o_server.R")

























# Validado ate aqui.


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



# Script to stop H2O Server
source("src/h2o/setup/stop_h2o_server.R")
