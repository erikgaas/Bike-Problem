test <- read.delim("D:/Dropbox/Kaggle Bike/filtered_test.txt")
#we want date year season holiday workinday weather all to be factors
test$date <- factor(test$date)
test$year <- factor(test$year)
test$is_weekend <- factor(test$is_weekend)
test$season <- factor(test$season)
test$holiday <- factor(test$holiday)
test$workingday <- factor(test$workingday)
test$weather <- factor(test$weather)

train <- read.delim("D:/Dropbox/Kaggle Bike/filtered_train.txt")
train$date <- factor(train$date)
train$is_weekend <- factor(train$is_weekend)
train$year <- factor(train$year)
train$season <- factor(train$season)
train$holiday <- factor(train$holiday)
train$workingday <- factor(train$workingday)
train$weather <- factor(train$weather)

library(gbm)
library(caret)
library(doParallel)

##all predictors including those engineered this syntax just builds us a nice formula without typing all 
##13 columns out by hand.
##we got rid of the less important one
casual_formula <-as.formula(paste0("casual~",paste(colnames(train[-c(3,14,15)]),collapse="+")))
registered_formula <- as.formula(paste0("registered~",paste(colnames(train[-c(3,14,15)]),collapse="+")))


##well first try didn't work so well. so let's train some parameters

cl <-makeCluster(detectCores())##now we're in windows
registerDoParallel(cl)


control <-trainControl(method="repeatedcv",number=10,repeats=10)
rf_casual<-train(casual_formula, 
                data = train,
                method="rf",
                trControl=control,
                prox=TRUE,
                allowParallel=TRUE)
rf_registered<-train(registered_formula,
                     data= train,
                     method="rf",
                     trControl=control,
                     prox=TRUE,
                     allowParallel=TRUE)
##Generate results
setwd("D:/Dropbox/Kaggle Bike")
result<- round(predict(rf_casual) + predict(rf_registered),0)
sampleSubmission <- read.csv("D:/Dropbox/Kaggle Bike/sampleSubmission.csv")
sampleSubmission$count <- result
write.csv(sampleSubmission,file='rftest.csv',row.names=F)

