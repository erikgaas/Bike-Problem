test <- read.delim("~/Desktop/Bike-Problem/filtered_test.txt")
# test$hour <- factor(test$hour)
# test$year <- factor(test$year)
# test$season <- factor(test$season)
# test$holiday <- factor(test$holiday)
# test$workingday <- factor(test$workingday)
# test$weather <- factor(test$weather)

train <- read.delim("~/Desktop/Bike-Problem/filtered_train.txt")
# train$hour <- factor(train$hour)
# train$year <- factor(train$year)
# train$season <- factor(train$season)
# train$holiday <- factor(train$holiday)
# train$workingday <- factor(train$workingday)
# train$weather <- factor(train$weather)


library(gbm)
library(caret)
library(doParallel)
library(randomForest)
library(MASS)


cl <-makeCluster(4)
registerDoParallel(cl)

casual_formula <-as.formula(paste0("casual~",paste(colnames(train[-c(13,14)]),collapse="+")))
registered_formula <- as.formula(paste0("registered~",paste(colnames(train[-c(13,14)]),collapse="+")))



#hold out .25 to estimate kaggle score
train_idx <-createDataPartition(train$casual,p=.75,list=F)
train_train <-train[train_idx,]
train_train$casual <-log(train_train$casual+1)

train_train$registered <-log(train_train$registered+1)
#trying out logs

train_test <- train[-train_idx,]
train_test_casual <- train_test$casual
train_test_registered <- train_test$registered
train_test <- train_test[,-c(13,14)]

train_train_casual <-train_train[,13]
train_train_registered <-train_train[,14]
train_train<-train_train[,-c(13,14)]
trans <- preProcess(train_train,method=c("BoxCox","center","scale","pca"))

