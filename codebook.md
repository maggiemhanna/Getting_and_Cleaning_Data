Objectives
----------

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

<http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>

Here are the data for the project:

<https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>

We create one R script called run\_analysis.R that does the following.

-   Merges the training and the test sets to create one data set.
-   Extracts only the measurements on the mean and standard deviation for each measurement.
-   Uses descriptive activity names to name the activities in the data set
-   Appropriately labels the data set with descriptive variable names.
-   From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

This file describes the steps performed in order to create the a Tidy data.

Required Libraries
------------------

The libraries used in this project are:

``` r
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library(tidyr)
library(knitr)
```

Getting the Data
----------------

### Changing Working Directory

Change the value of the path depending on the working directory

``` r
path <- "~/Dropbox/3 Data Science Specialization/Course 3 - Getting and cleaning data/Getting_Cleaning_Data_Project"
setwd(path)
```

### Downloading the file

``` r
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="Dataset.zip",method="curl")
```

### Unzip the file and create a data path

``` r
unzip(zipfile="Dataset.zip")
path_rf <- file.path("UCI HAR Dataset")
```

### Collecting Training Set

``` r
subject_train <- read.table(file.path(path_rf, "train","subject_train.txt"))
X_train <- read.table(file.path(path_rf, "train","X_train.txt"))
y_train <- read.table(file.path(path_rf, "train","y_train.txt"))
```

### Collecting Testing Set

``` r
subject_test <- read.table(file.path(path_rf, "test","subject_test.txt"))
X_test <- read.table(file.path(path_rf, "test","X_test.txt"))
y_test <- read.table(file.path(path_rf, "test","y_test.txt"))
```

Merging the training and the test sets to create one data set
-------------------------------------------------------------

We merge the training data and the testing data by row, and we merge the features, the subject and the activity:

``` r
subject <- rbind(subject_train, subject_test)
X <- rbind(X_train, X_test)
y <- rbind(y_train, y_test)

names(subject) <- "Subject"
names(y) <- "Activity"

df <- cbind(X,subject,y)
```

Using descriptive activity names to name the activities in the data set
-----------------------------------------------------------------------

``` r
activity_labels <- read.table(file.path(path_rf,"activity_labels.txt"))

names(activity_labels) <- c("ActivityNum","ActivityLabel")

df <- select(merge(df,activity_labels, by.x = "Activity", by.y = "ActivityNum"),-Activity, Activity = ActivityLabel)
```

Getting feature names and attributing them to column names
----------------------------------------------------------

### Getting features names

``` r
features <- read.table(file.path(path_rf,"features.txt"))  
names(features) <- c('FeatureNum','FeatureName')
features$FeatureCode <- paste0("V",features$FeatureNum)
```

### Extracting only the measurements on the mean and standard deviation for each measurement

``` r
df_features <- features[grep("mean\\(\\)|std\\(\\)",features$FeatureName),]
df <- df[c(df_features$FeatureCode,"Subject","Activity")]
```

### Fixing feature names

``` r
df_features$FeatureName <- as.character(df_features$FeatureName)
df_features$FeatureName <- gsub('([[:upper:]])', '-\\1', df_features$FeatureName)
df_features$FeatureName <- gsub('--', '-\\1', df_features$FeatureName)
df_features[grepl("-Mag",df_features$FeatureName),"FeatureName"] <- 
    paste0(df_features[grepl("-Mag",df_features$FeatureName),"FeatureName"], "-Mag")
df_features$FeatureName <- sub("-Mag","",df_features$FeatureName)
df_features$FeatureName <- sub("-Body-Body","-Body",df_features$FeatureName)

df_features[!grepl("-Jerk",df_features$FeatureName),"FeatureName"] <- sub('-mean\\(\\)','-NoJerk-mean\\(\\)',df_features[!grepl("-Jerk",df_features$FeatureName),"FeatureName"])
df_features[!grepl("-Jerk",df_features$FeatureName),"FeatureName"] <- sub('-std\\(\\)','-NoJerk-std\\(\\)',df_features[!grepl("-Jerk",df_features$FeatureName),"FeatureName"])
```

### Attributing the Names in df\_features to the column names in df

``` r
names(df) <- c(df_features$FeatureName,"Subject","Activity")
```

Creating Tidy Data by seperating the columns
--------------------------------------------

``` r
df <- gather(df, Description, Value, -Subject, -Activity)
dfTidy <- separate(df, Description, c("Domain", "Acceleration", "Instrument", "Jerk", "Measure","Direction"))
```

Appropriately labels the data set with descriptive variable names
-----------------------------------------------------------------

Names of features are labeled using descriptive variable names.

-   prefix t is replaced by time
-   Acc is replaced by Accelerometer
-   Gyro is replaced by Gyroscope
-   prefix f is replaced by frequency
-   Mag is replaced by Magnitude
-   BodyBody is replaced by Body

``` r
dfTidy$Domain <- factor(dfTidy$Domain, labels=c("Freq","Time"))
dfTidy$Acceleration <- factor(dfTidy$Acceleration)
dfTidy$Instrument <- factor(dfTidy$Instrument,labels=c("Accelerometer","Gyroscope"))
dfTidy$Jerk <- factor(dfTidy$Jerk, labels = c("Jerk",NA))
dfTidy$Measure <- factor(dfTidy$Measure, labels = c("Mean","STD"))
dfTidy$Direction <- factor(dfTidy$Direction, labels = c("Magnitude","X","Y","Z"))
```

Order Tidy Data by Subject and Activity
---------------------------------------

``` r
dfTidy <- dfTidy[order(dfTidy$Subject,dfTidy$Activity),]
rownames(dfTidy) <- NULL
```

Creating a second, independent tidy data set with the average of each variable for each activity and each subject.
------------------------------------------------------------------------------------------------------------------

``` r
dfSummary <- summarise(group_by(dfTidy,Subject,Activity), mean(Value))
```

Exporting Data Tables
---------------------

``` r
write.table(dfTidy, "dfTidy.txt", row.names = FALSE)
write.table(dfSummary, "dfSummary.txt", row.names = FALSE)
```

### Displaying Tidy Data and its summary

``` r
options(width = 160)

kable(dfTidy[1:20,])
```

|  Subject| Activity | Domain | Acceleration | Instrument    | Jerk | Measure | Direction |       Value|
|--------:|:---------|:-------|:-------------|:--------------|:-----|:--------|:----------|-----------:|
|        1| LAYING   | Time   | Body         | Accelerometer | NA   | Mean    | X         |   0.2778302|
|        1| LAYING   | Time   | Body         | Accelerometer | NA   | Mean    | X         |  -0.0662389|
|        1| LAYING   | Time   | Body         | Accelerometer | NA   | Mean    | X         |   0.2802064|
|        1| LAYING   | Time   | Body         | Accelerometer | NA   | Mean    | X         |   0.2818277|
|        1| LAYING   | Time   | Body         | Accelerometer | NA   | Mean    | X         |   0.2767294|
|        1| LAYING   | Time   | Body         | Accelerometer | NA   | Mean    | X         |   0.2793712|
|        1| LAYING   | Time   | Body         | Accelerometer | NA   | Mean    | X         |   0.0190162|
|        1| LAYING   | Time   | Body         | Accelerometer | NA   | Mean    | X         |   0.2780065|
|        1| LAYING   | Time   | Body         | Accelerometer | NA   | Mean    | X         |   0.2757526|
|        1| LAYING   | Time   | Body         | Accelerometer | NA   | Mean    | X         |   0.2795748|
|        1| LAYING   | Time   | Body         | Accelerometer | NA   | Mean    | X         |   0.2781233|
|        1| LAYING   | Time   | Body         | Accelerometer | NA   | Mean    | X         |   0.2758836|
|        1| LAYING   | Time   | Body         | Accelerometer | NA   | Mean    | X         |   0.2765270|
|        1| LAYING   | Time   | Body         | Accelerometer | NA   | Mean    | X         |   0.2760395|
|        1| LAYING   | Time   | Body         | Accelerometer | NA   | Mean    | X         |   0.2783163|
|        1| LAYING   | Time   | Body         | Accelerometer | NA   | Mean    | X         |  -0.0832871|
|        1| LAYING   | Time   | Body         | Accelerometer | NA   | Mean    | X         |   0.2591151|
|        1| LAYING   | Time   | Body         | Accelerometer | NA   | Mean    | X         |   0.2767659|
|        1| LAYING   | Time   | Body         | Accelerometer | NA   | Mean    | X         |   0.2438979|
|        1| LAYING   | Time   | Body         | Accelerometer | NA   | Mean    | X         |   0.4034743|

``` r
kable(dfSummary[1:20,])
```

|  Subject| Activity            |  mean(Value)|
|--------:|:--------------------|------------:|
|        1| LAYING              |   -0.6815820|
|        1| SITTING             |   -0.7250103|
|        1| STANDING            |   -0.7518869|
|        1| WALKING             |   -0.1932046|
|        1| WALKING\_DOWNSTAIRS |   -0.1493580|
|        1| WALKING\_UPSTAIRS   |   -0.3153368|
|        2| LAYING              |   -0.7431268|
|        2| SITTING             |   -0.7373620|
|        2| STANDING            |   -0.7399703|
|        2| WALKING             |   -0.3254482|
|        2| WALKING\_DOWNSTAIRS |   -0.1064115|
|        2| WALKING\_UPSTAIRS   |   -0.2709486|
|        3| LAYING              |   -0.7343477|
|        3| SITTING             |   -0.7078454|
|        3| STANDING            |   -0.7120682|
|        3| WALKING             |   -0.3179478|
|        3| WALKING\_DOWNSTAIRS |   -0.2327084|
|        3| WALKING\_UPSTAIRS   |   -0.3583576|
|        4| LAYING              |   -0.7286680|
|        4| SITTING             |   -0.7178434|

### Checking the structures of the data frame

``` r
str(dfTidy)
```

    ## 'data.frame':    679734 obs. of  9 variables:
    ##  $ Subject     : int  1 1 1 1 1 1 1 1 1 1 ...
    ##  $ Activity    : Factor w/ 6 levels "LAYING","SITTING",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ Domain      : Factor w/ 2 levels "Freq","Time": 2 2 2 2 2 2 2 2 2 2 ...
    ##  $ Acceleration: Factor w/ 2 levels "Body","Gravity": 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ Instrument  : Factor w/ 2 levels "Accelerometer",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ Jerk        : Factor w/ 2 levels "Jerk",NA: 2 2 2 2 2 2 2 2 2 2 ...
    ##  $ Measure     : Factor w/ 2 levels "Mean","STD": 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ Direction   : Factor w/ 4 levels "Magnitude","X",..: 2 2 2 2 2 2 2 2 2 2 ...
    ##  $ Value       : num  0.2778 -0.0662 0.2802 0.2818 0.2767 ...

``` r
str(dfSummary)
```

    ## Classes 'grouped_df', 'tbl_df', 'tbl' and 'data.frame':  180 obs. of  3 variables:
    ##  $ Subject    : int  1 1 1 1 1 1 2 2 2 2 ...
    ##  $ Activity   : Factor w/ 6 levels "LAYING","SITTING",..: 1 2 3 4 5 6 1 2 3 4 ...
    ##  $ mean(Value): num  -0.682 -0.725 -0.752 -0.193 -0.149 ...
    ##  - attr(*, "vars")=List of 1
    ##   ..$ : symbol Subject
    ##  - attr(*, "drop")= logi TRUE

Data and Variables Description
------------------------------

| Variable     | Description                                                                            |
|:-------------|:---------------------------------------------------------------------------------------|
| Subject      | The subject who performed the activity for each window sample                          |
| Activity     | The activity being performed (WALKING, WALKING\_UPSTAIRS, ...)                         |
| Domain       | Indicates whether the measure is a time domain or a frequency domain signal            |
| Acceleration | The acceleration signal is separated into body and gravity acceleration signals        |
| Instrument   | The instrument (accelerometer or gyroscope) used to measure the signal                 |
| Jerk         | Indicates whether the signal is a Jerk signal or not                                   |
| Measure      | The set of variables estimated from these signals                                      |
| Direction    | Indicates whether the measured signal is an axial signal (X,Y,Z) or a magnitude signal |
| Value        | Value of the signal                                                                    |
