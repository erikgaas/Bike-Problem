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
#weekends are really important but i'm not sold on dates mattering
#visualize this using
#aggregate(train$casual,list(train$date),mean) -- take the mean of casual by group date
#play around graphing these gives a really good summary of data


##lets use gradient boosted trees trying to predict casual and registered as two different models
##maybe make a model for each day of the week??

##chose decision tree methods because I believe it is a non linear regression.

##we're going to model casual and registered seperataly
##this is pretty clear from the data that casual people bike on weekends and registered are mostly 
##commuters. There would be interference if we kept them together.


##all predictors including those engineered this syntax just builds us a nice formula without typing all 
##13 columns out by hand.
##we got rid of the less important one


train_idx <-createDataPartition(train$casual,p=.75,list=F)
train_train <-train[train_idx,]
train_test <- train[-train_idx,]
train_test_casual <- train_test$casual
train_test_registered <- train_test$registered
train_test <- train_test[,-c(13,14)]

casual_formula <-as.formula(paste0("casual~",paste(colnames(train[-c(13,14)]),collapse="+")))
registered_formula <- as.formula(paste0("registered~",paste(colnames(train[-c(13,14)]),collapse="+")))


##well first try didn't work so well. so let's train some parameters
library(caret)
##massively shrunk parameters let's see how this runs
library(gbm)

gbm_casual<- gbm(casual_formula,n.trees=3000,data=train_train,
                 distribution="gaussian",interaction.depth=10,
                 train.fraction=.8,cv.folds=10)
gbm_registered <- gbm(registered_formula,n.trees=5000,data=train_train,
                      distribution="gaussian",interaction.depth=10,
                      train.fraction=.8,cv.folds=10)


predicted_casual <- predict(gbm_casual,train_test)
predicted_registered <- predict(gbm_registered,train_test)
predicted_total <- predicted_casual + predicted_registered
actual_total <- train_test_casual + train_test_registered
rmsle <- ((1/length(train_test_registered))*sum((log(predicted_total+1)-log(actual_total+1))**2))**.5

# ##Generate results
# setwd("~/Desktop/Bike-Problem")
# result<- round(predict(gbm_casual,test) + predict(gbm_registered,test),0)
# sampleSubmission <- read.csv("~/Desktop/Bike Problem/sampleSubmission.csv")
# sampleSubmission$count <- result
# write.csv(sampleSubmission,file='rftest',row.names=F)




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
