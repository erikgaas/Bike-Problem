test <- read.delim("~/Desktop/Kaggle Bike/filtered_test.txt")
#we want date year season holiday workinday weather all to be factors
test$date <- factor(test$date)
test$year <- factor(test$year)
test$is_weekend <- factor(test$is_weekend)
test$season <- factor(test$season)
test$holiday <- factor(test$holiday)
test$workingday <- factor(test$workingday)
test$weather <- factor(test$weather)

train <- read.delim("~/Desktop/Kaggle Bike/filtered_train.txt")
train$date <- factor(train$date)
train$is_weekend <- factor(train$is_weekend)
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
library(gbm)

##all predictors including those engineered this syntax just builds us a nice formula without typing all 
##13 columns out by hand.
##we got rid of the less important one
casual_formula <-as.formula(paste0("casual~",paste(colnames(train[-c(3,14,15)]),collapse="+")))
registered_formula <- as.formula(paste0("registered~",paste(colnames(train[-c(3,14,15)]),collapse="+")))


##well first try didn't work so well. so let's train some parameters
library(caret)

gbmGrid <-  expand.grid(interaction.depth = c(8, 12, 16,20),
                        n.trees = c(1000,2000,3000,5000),
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
setwd("~/Desktop/Kaggle Bike")
result<- round(predict(gbm_registered_best,test,n.trees=???) + predict(gbm_casual_best,test,n.trees=???wa),0)
sampleSubmission <- read.csv("~/Downloads/sampleSubmission.csv")
sampleSubmission$count <- result
write.csv(sampleSubmission,file='finaltest.csv',row.names=F)




# # Remniants from old code
# ##tuned using best info
# gbm_casual <- gbm(casual_formula,
#                   data=train,
#                   distribution="gaussian",
#                   n.trees=150,
#                   bag.fraction = 0.75,
#                   shrinkage=.1,
#                   cv.folds = 10,
#                   interaction.depth = 3)
# gbm_registered <- gbm(registered_formula,
#                       data=train,
#                       distribution="gaussian",
#                       n.trees=150,
#                       bag.fraction = 0.75,
#                       shrinkage=.1,
#                       cv.folds = 10,
#                       interaction.depth = 3)
# 
# ##tuning interaction depth and n.trees so far. havent' touched bag.fraction and cv.folds
# ##holy this takes like 15 minutes
# ##want plot to flatten but avoid overfitting this plot shows how well we're doing with error
# gbm_casual_perf <- gbm.perf(gbm_casual,method="cv")
# gbm_registered_perf <- gbm.perf(gbm_registered,method="cv")
# ##looks like 3000 is a lot. lets make predictions on our test data and submit
# 
