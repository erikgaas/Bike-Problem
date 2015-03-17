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

train$casual <-log(train$casual+1)
train$registered <-log(train$registered+1)

# #hold out .25 to estimate kaggle score
# train_idx <-createDataPartition(train$casual,p=.75,list=F)
# train_train <-train[train_idx,]
# train_train$casual <-log(train_train$casual+1)
# 
# train_train$registered <-log(train_train$registered+1)
# #trying out logs
# 
# train_test <- train[-train_idx,]
# train_test_casual <- train_test$casual
# train_test_registered <- train_test$registered
# train_test <- train_test[,-c(13,14)]

casual_formula <-as.formula(paste0("casual~",paste(colnames(train[-c(13,14)]),collapse="+")))
registered_formula <- as.formula(paste0("registered~",paste(colnames(train[-c(13,14)]),collapse="+")))


##well first try didn't work so well. so let's train some parameters
library(caret)
##massively shrunk parameters let's see how this runs
library(gbm)


##lets try to average em
gbm_casual<- gbm(casual_formula,n.trees=3000,data=train,
                 distribution="gaussian",interaction.depth=10,
                 train.fraction=.8,cv.folds=10)
gbm_registered <- gbm(registered_formula,n.trees=5000,data=train,
                      distribution="gaussian",interaction.depth=10,
                      train.fraction=.8,cv.folds=10)

##basic random forest
casual_forest_bias <- randomForest(casual_formula,data=train,ntree=1500,mtry=5,importance=T,
                                   corr.bias=T)
regist_forest_bias<- randomForest(registered_formula,data=train,ntree=1500,mtry=5,importance=T,
                                  corr.bias=T)

##predict kaggle score
predicted_casual_f <- exp(predict(casual_forest_bias,test))
predicted_registered_f <- exp(predict(regist_forest_bias,test))
predicted_total_f <- predicted_casual_f + predicted_registered_f


predicted_casual_g <- exp(predict(gbm_casual,test))
predicted_registered_g <- exp(predict(gbm_registered,test))
predicted_total_g <- predicted_casual_g + predicted_registered_g

predicted_total <- round((predicted_total_g+predicted_total_f)*.5,0)




# actual_total <- train_test_casual + train_test_registered
# 
#rmsle <- ((1/length(train_test_registered))*sum((log(predicted_total+1)-log(actual_total+1))**2))**.5

#Generate results
setwd("~/Desktop/Bike-Problem")
sampleSubmission <- read.csv("~/Desktop/Bike-Problem/sampleSubmission.csv")
sampleSubmission$count <- predicted_total
write.csv(sampleSubmission,file='log_test16th',row.names=F)




# gbmGridCasual <-  expand.grid(interaction.depth = c(20),
#                               n.trees = c(2500),
#                               shrinkage = c(0.1))
# gbmGridRegistered <- expand.grid(interaction.depth = c(20),
#                                  n.trees = c(6000),
#                                  shrinkage = c(0.1))
# 
# control <-trainControl(method="cv",number=10)
# gbm_casual_best<- train(casual_formula, data =train,
#                         method='gbm',
#                         trControl = control,
#                         tuneGrid = gbmGridCasual,
#                         preProc=c("center","scale"))
# 
# gbm_registered_best<-train(registered_formula,data=train,
#                            method='gbm',
#                            trControl=control,
#                            tuneGrid = gbmGridRegistered,
#                            preProc=c("center","scale"))
