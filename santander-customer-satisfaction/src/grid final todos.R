
library(h2o)
library(sas7bdat)
library(caret)
library(gbm)
library(xgboost)
library(data.table)
library(xgboost)
library(Matrix)
library(caret)
library(dplyr)
library(e1071)

h2o.init()

german<-read.sas7bdat("C:/germanredux.sas7bdat")

# **************************************
# EJEMPLO GRID GRADIENT BOOSTING
# **************************************

# 1) Se fija la manera de comparar. Aqu? validaci?n cruzada repetida. 

# Importante controlar la semilla 

set.seed(22345)
fitControl <- trainControl(method = "repeatedcv",number = 4,repeats = 10)

# 2) Se plantea la rejilla de par?metros y se ejecuta para comparar

grid <- expand.grid(interaction.depth=c(3,10),
n.trees = c(1000),
n.minobsinnode = c(5,10),
shrinkage = c(0.01,0.002))

model1<- train(factor(bad)~., data=train, method="gbm", 
 trControl = fitControl,tuneGrid=grid,verbose=FALSE)

# 3) Se observa el resultado y las mejores combinaciones de par?metros 
model1

# 4) El propio proceso guarda en model1 la mejor combinaci?n de par?metros y 
# se puede comparar los resultados con otros modelos

# Ejemplo regresi?n log?stica

model2<-train(factor(bad) ~ ., data = train,method = "glm",trControl = fitControl)

resa<-resamples(list(GBM=model1,LOGI=model2))

bwplot(resa)

difValues <- diff(resa)

dotplot(difValues)

# **************************************
# EJEMPLO GRID RANDOM FOREST
# (SOLO PERMITE VARIAR MTRY)
# **************************************

# Conservo el anterior fitControl de validaci?n cruzada para comparar
# todos los modelos que voy creando

grid2 <- expand.grid(mtry=c(2,4,6,8,10,12)) 
 
# En esta ejecucion no pongo numero de muestra y utiliza 
# por defecto todas las observaciones CON reemplazo

raforest <- train(factor(bad) ~ ., data = train,
method = "rf",trControl = fitControl,maxnodes=50,
 nodesize=10,ntree=5000,tuneGrid=grid2)

raforest

# Comparamos los tres modelos 
resa<-resamples(list(GBM=model1,LOGI=model2,RFOREST=raforest))
bwplot(resa)
difValues <- diff(resa)
dotplot(difValues)

# *********************************************************
# Ejemplo Grid con par?metros que no est?n considerados en caret
# Por ejemplo quiero variar maxnodes y mtry en random forest
# *********************************************************

# Creo datafin  y final archivo vac?o

datafin=data.frame(mtry=numeric(0),Accuracy=numeric(0),Kappa=numeric(0),
 AccuracySD=numeric(0),KappaSD=numeric(0),nodes=numeric(0))

final=data.frame(Accuracy=numeric(0),Kappa=numeric(0), nodes=numeric(0),mtr=numeric(0))

# bucle para maxnodes y mtry

for(maxinodes in c(50,100))       {
 
 for(mtr in c(4,10))      { 

 grid3 <- expand.grid(mtry=c(mtr)) 
  
raforest <- train(factor(bad) ~ ., data = train,
method = "rf",trControl = fitControl,maxnodes=maxinodes,
nodesize=10,ntree=5000,tuneGrid=grid3)

#  El elemento 4 de la lista raforest son los resultados globales
#  y el 14 las muestras
 
dat<-as.data.frame(raforest[[4]])
dat$nodes<-maxinodes
datafin<-rbind(datafin,dat)

ver<-as.data.frame(raforest[[14]])
ver<-ver[,-3] 
ver$nodes<- maxinodes
ver$mtr<- mtr
final<-rbind(final,ver)
 
}}

boxplot(Accuracy ~ factor(nodes)+factor(mtr),data=final)

# *********************************************************
# EJEMPLOS GRID CON H2O
# *********************************************************

# h2o.gbm(x, y, training_frame, model_id, checkpoint, ignore_const_cols = TRUE,
# distribution = c("AUTO", "gaussian", "bernoulli", "multinomial", "poisson",
# "gamma", "tweedie", "laplace", "quantile"), quantile_alpha = 0.5,
# tweedie_power = 1.5, ntrees = 50, max_depth = 5, min_rows = 10,
# learn_rate = 0.1, sample_rate = 1, col_sample_rate = 1,
# col_sample_rate_per_tree = 1, nbins = 20, nbins_top_level,
# nbins_cats = 1024, validation_frame = NULL, balance_classes = FALSE,
# max_after_balance_size = 1, seed, build_tree_one_node = FALSE,
# nfolds = 0, fold_column = NULL, fold_assignment = c("AUTO", "Random",
# "Modulo"), keep_cross_validation_predictions = FALSE,
# score_each_iteration = FALSE, score_tree_interval = 0,
# stopping_rounds = 0, stopping_metric = c("AUTO", "deviance", "logloss",
# "MSE", "AUC", "r2", "misclassification"), stopping_tolerance = 0.001,
# max_runtime_secs = 0, offset_column = NULL, weights_column = NULL)
# 

# h2o.randomForest(x, y, training_frame, model_id, validation_frame = NULL,
# ignore_const_cols = TRUE, checkpoint, mtries = -1, sample_rate = 0.632,
# col_sample_rate_per_tree = 1, build_tree_one_node = FALSE, ntrees = 50,
# max_depth = 20, min_rows = 1, nbins = 20, nbins_top_level,
# nbins_cats = 1024, binomial_double_trees = FALSE,
# balance_classes = FALSE, max_after_balance_size = 5, seed,
# offset_column = NULL, weights_column = NULL, nfolds = 0,
# fold_column = NULL, fold_assignment = c("AUTO", "Random", "Modulo"),
# keep_cross_validation_predictions = FALSE, score_each_iteration = FALSE,
# score_tree_interval = 0, stopping_rounds = 0,
# stopping_metric = c("AUTO", "deviance", "logloss", "MSE", "AUC", "r2",
# "misclassification"), stopping_tolerance = 0.001, max_runtime_secs = 0)
# 

# Creo split train test 

train<-sample_frac(german, 0.8)
sid<-as.numeric(rownames(train)) # because rownames() returns character
test<-german[-sid,]

bad<-as.factor(train$bad)

germantrain.hex <- as.h2o(train, destination_frame="germantrain.hex")
germantest.hex <- as.h2o(test, destination_frame="germantest.hex")


# Pruebo Grid

gridgbm <- h2o.grid("gbm", x = c(1:13), y = "bad",
 training_frame = germantrain.hex,
 validation_frame=germantest.hex,
 hyper_params = list(ntrees = c(12000),learn_rate=c(0.002,0.01),
 max_depth=c(10),min_rows=c(5)))
 
summary(gridgbm)

# Aplico modelo sobre datos test

salidagbm<-h2o.gbm(y ="bad", x = c(1:13), training_frame = germantrain.hex,
ntrees = 12000, max_depth = 10, min_rows = 5,learn_rate=0.01,
distribution = "AUTO")

predite<-h2o.predict(salidagbm, germantest.hex)
summary(predite)
predite<-as.data.frame(predite)
testbad<-test$bad

union<-cbind(predite,testbad)

union$predi <- ifelse(union$predict >0.5,
c(1), c(0)) 

confu<-confusionMatrix(union$predi,union$testbad)
confu 

# Pruebo Grid Random forest

gridfor<-h2o.grid("randomForest",y ="bad", x = c(1:13),
 training_frame = germantrain.hex,
 validation_frame=germantest.hex, 
 hyper_params = list(mtries=c(6,10),
 sample_rate=0.8,min_rows=10,ntrees=1000))

summary(gridfor)

# Aplico modelo sobre datos test

salidafor<-h2o.randomForest(y ="bad", x = c(1:13), 
training_frame = germantrain.hex,
ntrees = 1000, mtries= 10, min_rows = 10,sample_rate=0.8
)

predite<-h2o.predict(salidafor, germantest.hex)
summary(predite)
predite<-as.data.frame(predite)
testbad<-test$bad
union<-cbind(predite,testbad)

union$predi <- ifelse(union$predict >0.5,
c(1), c(0)) 

confu<-confusionMatrix(union$predi,union$testbad)
confu 

# **********************************************************************
# Ejemplo final comparando gbm y rforest basicos con los de h2o
# Aqu? utilizo TRAIN-TEST para comparar
# Tambi?n pruebo xgboost
# **********************************************************************

# Creo split train test 


german<-read.sas7bdat("C:/germanredux.sas7bdat")
set.seed(12346)

train<-sample_frac(german, 0.7)
sid<-as.numeric(rownames(train)) # because rownames() returns character
test<-german[-sid,]

bad<-as.factor(train$bad)


testbad<-test$bad

germantrain.hex <- as.h2o(train, destination_frame="germantrain.hex")
germantest.hex <- as.h2o(test, destination_frame="germantest.hex")


# GBM

gbm5<-gbm(bad~., data=train,distribution = "bernoulli",
 ,n.trees=5000,n.minobsinnode=5,shrinkage = 0.02,
interaction.depth=10)

predite<-predict.gbm(gbm5,n.trees=5000,test)

summary(predite)

predite<-as.data.frame(predite)
testbad<-test$bad
union<-cbind(predite,testbad)

union$predi <- ifelse(union$predite >0,
c(1), c(0)) 

confu<-confusionMatrix(union$predi,union$testbad)
confu1<-as.data.frame(confu[[3]])
confu1$modelo<-"GBM5"
confu1<-confu1[1,]

datatrain<-data.matrix(train[,-14])
datatest<-data.matrix(test[,-14])

bad2<-train$bad

modeloxgb <- xgboost(data =datatrain, label = bad2, 
 eta = 0.02, max_depth =6,  nround=12000,  colsample_bytree = 1,
  eval_metric = "error", objective = "binary:logistic", 
 min_child_weight=5,subsample=1, verbose=0)

predite <- predict(modeloxgb,datatest)

predite<-as.data.frame(predite)
testbad<-test$bad
union<-cbind(predite,testbad)

union$predi <- ifelse(union$predite >0.5,
c(1), c(0)) 

confu<-confusionMatrix(union$predi,union$testbad)
confu2<-as.data.frame(confu[[3]])
confu2$modelo<-"XGBOOST"
confu2
confu2<-confu2[1,]

rforest<-randomForest(bad~., data=train,distribution = "bernoulli",mtry=10,n.trees=2000)

predite<-predict.gbm(gbm5,n.trees=2000,test)

summary(predite)

predite<-as.data.frame(predite)
testbad<-test$bad
union<-cbind(predite,testbad)

union$predi <- ifelse(union$predite >0,
c(1), c(0)) 

confu<-confusionMatrix(union$predi,union$testbad)
confu3<-as.data.frame(confu[[3]])
confu3$modelo<-"Rforest"
confu3
confu3<-confu3[1,]

bad<-as.factor(train$bad)

salidagbm<-h2o.gbm(y ="bad", x = c(1:13), training_frame = germantrain.hex,
ntrees = 10000, max_depth = 10, min_rows = 5,learn_rate=0.01,
distribution = "AUTO")

predite<-h2o.predict(salidagbm, germantest.hex)
summary(predite)
predite<-as.data.frame(predite)
testbad<-test$bad

union<-cbind(predite,testbad)

union$predi <- ifelse(union$predict >0.5,
c(1), c(0)) 

confu<-confusionMatrix(union$predi,union$testbad)
confu4<-as.data.frame(confu[[3]])
confu4$modelo<-"GBM-H2O"
confu4

confu4<-confu4[1,]

salidafor<-h2o.randomForest(y ="bad", x = c(1:13), 
training_frame = germantrain.hex,
ntrees = 2000, mtries= 10, min_rows = 10,sample_rate=0.8
)

predite<-h2o.predict(salidafor, germantest.hex)
summary(predite)
predite<-as.data.frame(predite)
testbad<-test$bad
union<-cbind(predite,testbad)

union$predi <- ifelse(union$predict >0.5,
c(1), c(0)) 

confu<-confusionMatrix(union$predi,union$testbad)
confu5<-as.data.frame(confu[[3]])
confu5$modelo<-"GBM-H2O"
confu5

confu5<-confu5[1,]


unionconfu<-rbind(confu1,confu2,confu3,confu4,confu5)



