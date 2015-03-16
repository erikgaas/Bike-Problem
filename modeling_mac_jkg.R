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
casual_formula <-as.formula(paste0("casual~",paste(colnames(train[-c(14,15)]),collapse="+")))
registered_formula <- as.formula(paste0("registered~",paste(colnames(train[-c(14,15)]),collapse="+")))


##well first try didn't work so well. so let's train some parameters
library(caret)
##massively shrunk parameters let's see how this runs

library(doParallel)
library(gbm)
cl <-makeCluster(4)##now we're in windows
registerDoParallel(cl)

gbmGrid <-  expand.grid(interaction.depth = c(20),
                        n.trees = c(2500,5000),
                        shrinkage = c(0.1,.001,.0001))

control <-trainControl(method="repeatedcv",number=10,repeats=10)
gbm_casual_best<- train(casual_formula, data =train,
                        method='gbm',
                        trControl = control,
                        tuneGrid = gbmGrid,
                        preProc=c("center","scale"))

gbm_registered_best<-train(registered_formula,data=train,
                           method='gbm',
                           trControl=control,
                           tuneGrid = gbmGrid,
                           preProc=c("center","scale"))


##Generate results
setwd("~/Desktop/Bike Problem")
result<- round(predict(gbm_casual_best,test) + predict(gbm_registered_best,test),0)
sampleSubmission <- read.csv("~/Desktop/Bike Problem/sampleSubmission.csv")
sampleSubmission$count <- result
write.csv(sampleSubmission,file='rftest',row.names=F)


