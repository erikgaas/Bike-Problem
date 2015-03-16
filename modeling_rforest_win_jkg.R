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

casual_formula <-as.formula(paste0("casual~",paste(colnames(train[-c(13,14)]),collapse="+")))
registered_formula <- as.formula(paste0("registered~",paste(colnames(train[-c(13,14)]),collapse="+")))



cl <-makeCluster(2)##now we're in windows
registerDoParallel(cl)

##basic random forest
simple_forest_casual <- randomForest(casual_formula,data=train)
simple_forest_regist <- randomForest(registered_formula,data=train)



##Generate results
setwd("~/Desktop/Bike-Problem")
result<- round(predict(simple_forest_casual,test) + predict(simple_forest_regist,test),0)
sampleSubmission <- read.csv("~/Desktop/Bike Problem/sampleSubmission.csv")
sampleSubmission$count <- result
write.csv(sampleSubmission,file='rftest',row.names=F)

