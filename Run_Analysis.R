## Required Libraries

library(dplyr)
library(tidyr)

## Change Working Directory

path <- "/Users/admin/Dropbox/3 Data Science Specialization/Course 3 - Getting and cleaning data/Getting_Cleaning_Data_Project"
setwd(path)

## Download the file

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="Dataset.zip",method="curl")

## Unzip the file

unzip(zipfile="Dataset.zip")


## File path

path_rf <- file.path("UCI HAR Dataset")

## Collecting Training Set

subject_train <- read.table(file.path(path_rf, "train","subject_train.txt"))
X_train <- read.table(file.path(path_rf, "train","X_train.txt"))
y_train <- read.table(file.path(path_rf, "train","y_train.txt"))

## Collecting Testing Set

subject_test <- read.table(file.path(path_rf, "test","subject_test.txt"))
X_test <- read.table(file.path(path_rf, "test","X_test.txt"))
y_test <- read.table(file.path(path_rf, "test","y_test.txt"))

## Merging the training and the test sets to create one data set

subject <- rbind(subject_train, subject_test)
X <- rbind(X_train, X_test)
y <- rbind(y_train, y_test)

names(subject) <- "Subject"
names(y) <- "Activity"

df <- cbind(X,subject,y)

## Loading features names 

features <- read.table(file.path(path_rf,"features.txt"))  
names(features) <- c('FeatureNum','FeatureName')
features$FeatureCode <- paste0("V",features$FeatureNum)


## Extracting only the measurements on the mean and standard deviation for each measurement

df_features <- features[grep("mean\\(\\)|std\\(\\)",features$FeatureName),]
df <- df[c(df_features$FeatureCode,"Subject","Activity")]


## Using descriptive activity names to name the activities in the data set

activity_labels <- read.table(file.path(path_rf,"activity_labels.txt"))

names(activity_labels) <- c("ActivityNum","ActivityLabel")

df <- select(merge(df,activity_labels, by.x = "Activity", by.y = "ActivityNum"),-Activity, Activity = ActivityLabel)

## Fixing feature names in df_features 

df_features$FeatureName <- as.character(df_features$FeatureName)
df_features$FeatureName <- gsub('([[:upper:]])', '-\\1', df_features$FeatureName)
df_features$FeatureName <- gsub('--', '-\\1', df_features$FeatureName)
df_features[grepl("-Mag",df_features$FeatureName),"FeatureName"] <- 
    paste0(df_features[grepl("-Mag",df_features$FeatureName),"FeatureName"], "-Mag")
df_features$FeatureName <- sub("-Mag","",df_features$FeatureName)
df_features$FeatureName <- sub("-Body-Body","-Body",df_features$FeatureName)

df_features[!grepl("-Jerk",df_features$FeatureName),"FeatureName"] <- sub('-mean\\(\\)','-NoJerk-mean\\(\\)',df_features[!grepl("-Jerk",df_features$FeatureName),"FeatureName"])
df_features[!grepl("-Jerk",df_features$FeatureName),"FeatureName"] <- sub('-std\\(\\)','-NoJerk-std\\(\\)',df_features[!grepl("-Jerk",df_features$FeatureName),"FeatureName"])


## Attributing the Names in df_features to the column names in df
names(df) <- c(df_features$FeatureName,"Subject","Activity")


## Creating Tidy Data by seperating the columns
df <- gather(df, Description, Value, -Subject, -Activity)
dfTidy <- separate(df, Description, c("Domain", "Acceleration", "Instrument", "Jerk", "Measure","Direction"))

## Assocaiting each column with it corresponding data type

dfTidy$Domain <- factor(dfTidy$Domain, labels=c("Freq","Time"))
dfTidy$Acceleration <- factor(dfTidy$Acceleration)
dfTidy$Instrument <- factor(dfTidy$Instrument,labels=c("Accelerometer","Gyroscope"))
dfTidy$Jerk <- factor(dfTidy$Jerk, labels = c("Jerk",NA))
dfTidy$Measure <- factor(dfTidy$Measure, labels = c("Mean","STD"))
dfTidy$Direction <- factor(dfTidy$Direction, labels = c("Magnitude","X","Y","Z"))

## Order Tidy Data by Subject and Activity
dfTidy <- dfTidy[order(dfTidy$Subject,dfTidy$Activity),]

## creating a second, independent tidy data set with the average of each variable for each activity and each subject.

dfSummary <- summarise(group_by(dfTidy,Subject,Activity), mean(Value))

## Exporting Data Tables
write.table(dfTidy, "dfTidy.txt", row.names = FALSE)
write.table(dfSummary, "dfSummary.txt", row.names = FALSE)
