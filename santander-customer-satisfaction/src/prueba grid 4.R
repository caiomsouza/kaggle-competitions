rm(list = ls())
setwd("~/git/github.com/kaggle-competitions/santander-customer-satisfaction")

# Script to load the Train and Test Dataset
source("src/utils/load_datasets.R")

# Script to clean the Train and Test Dataset
source("src/utils/clean_datasets.R")

# Explore Dataset
head(train,5)
head(test,5)
nrow(train)
nrow(test)
colnames(train)
colnames(test)


library(sas7bdat)
library(caret)
library(gbm)

# Control de semilla importante para validaci?n cruzada

#german<-read.sas7bdat("C:/germanredux.sas7bdat")
#train<-german
#bad<-train$bad

y <- train$TARGET

set.seed(1000)
fitControl <- trainControl(method = "repeatedcv",number = 4,repeats = 10)

# Ejemplo grid para gbm
gbmGrid <-  expand.grid(interaction.depth = c(3,6),
                        n.trees = c(100),
                        shrinkage =c(0.1,0.02),
                        n.minobsinnode = c(5,10))

gbmFit1 <- train(factor(y) ~ ., data = train,
                 method = "gbm",trControl = fitControl,
                 verbose = FALSE,tuneGrid=gbmGrid)
gbmFit1

# Una vez decididos los par?metros los fijo para comparar con log?stica
# y random forest

# The final values used for the model were n.trees = 100, interaction.depth = 3, shrinkage = 0.02 and n.minobsinnode = 5.

gbmGrid <-  expand.grid(interaction.depth = c(3),
                        n.trees = c(100),shrinkage =c(0.02),
                        n.minobsinnode = c(5))

gbmFit2 <- train(factor(y) ~ ., data = train,
                 method = "gbm",trControl = fitControl,
                  verbose = FALSE,tuneGrid=gbmGrid)


logisfit <- train(factor(y) ~ ., data = train,
                 method = "glm",trControl = fitControl)

logisfit

# **************************************
# EJEMPLO GRID RANDOM FOREST
# (SOLO PERMITE VARIAR MTRY)
# **************************************

# Conservo el anterior fitControl de validaci?n cruzada para comparar
# todos los modelos que voy creando

grid2 <- expand.grid(mtry=c(4,8,10)) 
 
# En esta ejecucion no pongo numero de muestra y utiliza 
# por defecto todas las observaciones CON reemplazo

raforest <- train(factor(y) ~ ., data = train,
method = "rf",trControl = fitControl,maxnodes=50,
 nodesize=10,ntree=100,tuneGrid=grid2)

raforest

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
  
raforest <- train(factor(y) ~ ., data = train,
method = "rf",trControl = fitControl,maxnodes=maxinodes,
nodesize=10,ntree=200,tuneGrid=grid3)

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

# Suponiendo que el mejor modelo Randomforest tiene 100 nodos, 4 variables

grid3 <- expand.grid(mtry=c(4)) 

raforest <- train(factor(y) ~ ., data = train,
method = "rf",trControl = fitControl,maxnodes=100,
nodesize=10,ntree=1000,tuneGrid=grid3)


# Aqu? uno todas las muestras validaci?n cruzada de los tres modelos
resamps <- resamples(list(GBM = gbmFit2,LOGI = logisfit,RFOREST=raforest))

# Gr?ficos comparativos. Accuracy=Tasa de aciertos

bwplot(resamps,metric = "Accuracy")

dotplot(resamps, metric = "Accuracy")


