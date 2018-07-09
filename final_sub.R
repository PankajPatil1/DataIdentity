rm(list=ls())
list.of.packages <- c("h2o", "e1071","caret","MASS","dplyr","mice","xgboost")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(h2o)
library(e1071)
library(caret)
library(MASS)
library(dplyr)
library(mice)
library(xgboost)

train <- read.csv("train.csv",stringsAsFactors = FALSE)

train.no <- dim(train)[1]
data <- train
data$difficulty_level <-  as.numeric(factor(data$difficulty_level,levels=c("easy","intermediate","hard","vary hard"),labels=c(0,1,2,3),ordered = TRUE))
data$education <-  as.numeric(factor(data$education ,levels=c("No Qualification","High School Diploma","Matriculation","Bachelors","Masters"),labels=c(0,1,2,3,4),,ordered = TRUE))
data$total_hours <- data$program_duration * data$total_programs_enrolled
data$test_type <- factor(data$test_type, levels=c("offline","online"),labels=c(0,1),ordered =FALSE)
data$is_handicapped <- factor(data$is_handicapped, levels=c("N","Y"),labels=c(0,1),ordered =FALSE)
data$gender <- factor(data$gender, levels=c("M","F"),labels=c(0,1),ordered =FALSE)
data$program_type <- factor(data$program_type, levels=c("S","T","U","V","X","Y","Z"),labels=c(0:6),ordered =FALSE)
data$program_id <- as.numeric(gsub(".*_","",data$program_id))
data$id <- gsub("_.*","",data$id)
passers <- data.frame(data$trainee_id,data$is_pass)
# data[,c(12,17)] <- scale(data[,c(12,17)] )
data <- select(data,-c(1,4,8,13))

dummies <- dummyVars(~program_id+program_type+test_id+test_type+difficulty_level+gender+education+city_tier+is_handicapped+trainee_engagement_rating,data=data)
data2 <- predict(dummies,newdata=data)
data <- data.frame(data2,age=data$age,is_pass=data$is_pass)
#Prepare an imputer model
imputed.data <- mice(data,m=1,maxit=3,method="pmm",seed=500)
data <- complete(imputed.data,1)

# Prepare test data
test <- read.csv("test.csv")
id <- test$id
test$difficulty_level <-  as.numeric(factor(test$difficulty_level,levels=c("easy","intermediate","hard","vary hard"),labels=c(0,1,2,3)))
test$education <-  as.numeric(factor(test$education ,levels=c("No Qualification","High School Diploma","Matriculation","Bachelors","Masters"),labels=c(0,1,2,3,4)))
test$total_hours <- test$program_duration * test$total_programs_enrolled
test$test_type <- factor(test$test_type, levels=c("offline","online"),labels=c(0,1),ordered =FALSE)
test$is_handicapped <- factor(test$is_handicapped, levels=c("N","Y"),labels=c(0,1),ordered =FALSE)
test$gender <- factor(test$gender, levels=c("M","F"),labels=c(0,1),ordered =FALSE)
test$program_type <- factor(test$program_type, levels=c("S","T","U","V","X","Y","Z"),labels=c(0:6),ordered =FALSE)
test$program_id <- as.numeric(gsub(".*_","",test$program_id))
test <- select(test,-c(1,4,8,13))
dummies <- dummyVars(~program_id+program_type+test_id+test_type+difficulty_level+gender+education+city_tier+is_handicapped+trainee_engagement_rating,data=test)
test2 <- predict(dummies,newdata=test)
test <- data.frame(test2,age=test$age)
imputed.test <- mice(test,m=1,maxit=3,method="pmm",seed=500)
test <- complete(imputed.test,1)
rm(data2)
rm(test2)
#K fold validation
data <- sapply(data,as.numeric)
test <- sapply(test,as.numeric)
folds <- createFolds(data[,21],k=5)
# 
# cv=lapply(folds, function(x){
#   training_fold  <-  data[-x,]
#   test_fold  <-  data[x,]
#   classifier <- xgboost(data=as.matrix(training_fold[,-21]),label=as.matrix(training_fold[,21]),eta = 0.1,
#                         max_depth = 25, 
#                         nround=25, 
#                         subsample = 0.7,
#                         colsample_bytree = 0.5
#                       )
#   y_pred <- ifelse(predict(classifier,newdata=as.matrix(test_fold[,-21]))>0.5,1,0)
#   cm <- table(test_fold[,21],y_pred)
#   accuracy <- (cm[1,1]+cm[2,2])/(cm[1,1]+cm[1,2]+cm[2,1]+cm[2,2])
#   return(accuracy)
# })
classifier <- xgboost(data=as.matrix(data[,-21]),label=as.matrix(data[,21]),eta = 0.1,
                      max_depth = 24, 
                      nround=25, 
                      subsample = 0.7,
                      colsample_bytree = 0.5)
y_pred <- (predict(classifier,newdata=as.matrix(test)))
classifier2 <- knn3(formula=is_pass~.,data=data,k=3)
y_pred2 <- predict(classifier2,newdata=as.data.frame(test))
y_pred2 <- y_pred2[,2]
# classifier3 <- lm(formula=is_pass~.,data=as.data.frame(data))
# y_pred3 <- predict(classifier3,newdata = as.data.frame(test))
h2o.init(nthreads = -1)
classifier4 <- h2o.deeplearning(training_frame =as.h2o(data),y="is_pass",hidden=c(20,20))
y_pred4 <- h2o.predict(classifier4,newdata = as.h2o(test))
base <- data.frame(xgb=y_pred,knn=y_pred2,ann=as.vector(y_pred4))
base$weighted <- (base$xgb*0.5+base$knn*0.05+base$ann*0.45)

results <- data.frame(id=id,is_pass=base$weighted)
results$id2 <- as.numeric(gsub("_.*","",id))
vec <- vector()
passers$data.is_pass <- as.numeric(passers$data.is_pass)
pass.count <- data.frame(tapply(passers$data.is_pass,passers$data.trainee_id,sum))
pass.count[,1] <- as.numeric(pass.count[,1])
pass.count[,2] <- rownames(pass.count)
total.count <- data.frame(table(passers$data.trainee_id))
# total.count[,1] <- as.numeric(total.count[,1])
passers <- merge(pass.count,total.count,by.x="V2",by.y="Var1")
passers$is_pass <- passers$tapply.passers.data.is_pass..passers.data.trainee_id..sum./passers$Freq
passers$tapply.passers.data.is_pass..passers.data.trainee_id..sum. <- NULL
passers$Freq <- NULL
merged <- merge(results,passers,by.x="id2",by.y="V2",all.x=TRUE)
merged$is_pass <- merged$is_pass.y*0.3 + merged$is_pass.x*0.7
dim1 <- dim(merged)[1]
for(i in 1:dim1){
  if(is.na(merged$is_pass.y[i])){
    merged$is_pass[i]=merged$is_pass.x[i]
  }  
}
merged$id2 <- NULL
merged$is_pass.x <- NULL
merged$is_pass.y <- NULL


write.csv(merged,"extra.csv",row.names=FALSE)
  