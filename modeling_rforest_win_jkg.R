test <- read.delim("~/Desktop/Bike-Problem/filtered_test.txt")
test$hour <- factor(test$hour)
test$year <- factor(test$year)
test$season <- factor(test$season)
test$holiday <- factor(test$holiday)
test$workingday <- factor(test$workingday)
test$weather <- factor(test$weather)

train <- read.delim("~/Desktop/Bike-Problem/filtered_train.txt")
train$hour <- factor(train$hour)
train$year <- factor(train$year)
train$season <- factor(train$season)
train$holiday <- factor(train$holiday)
train$workingday <- factor(train$workingday)
train$weather <- factor(train$weather)


library(gbm)
library(caret)
library(doParallel)
library(randomForest)

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




casual_formula <-as.formula(paste0("casual~",paste(colnames(train[-c(13,14)]),collapse="+")))
registered_formula <- as.formula(paste0("registered~",paste(colnames(train[-c(13,14)]),collapse="+")))

cl <-makeCluster(4)
registerDoParallel(cl)

##basic random forest
casual_forest_bias <- randomForest(casual_formula,data=train_train,ntree=1000,mtry=5,importance=T,
                                     corr.bias=T)
regist_forest_bias<- randomForest(registered_formula,data=train_train,ntree=1000,mtry=5,importance=T,
                                  corr.bias=T)
##predict kaggle score
predicted_casual <- exp(predict(casual_forest_bias,train_test))
predicted_registered <- exp(predict(regist_forest_bias,train_test))
predicted_total <- predicted_casual + predicted_registered
actual_total <- train_test_casual + train_test_registered
rmsle <- ((1/length(train_test_registered))*sum((log(predicted_total+1)-log(actual_total+1))**2))**.5
print(rmsle)


# ##Generate results
# setwd("~/Desktop/Bike-Problem")
# result_tree<- round(predict(simple_forest_casual,test) + predict(simple_forest_regist,test),0)
# sampleSubmission <- read.csv("~/Desktop/Bike-Problem/sampleSubmission.csv")
# sampleSubmission$count <- result
# write.csv(sampleSubmission,file='rftest.csv',row.names=F)

