Overview
--------

This project serves to demonstrate the collection and cleaning of a tidy data set that can be used for subsequent analysis. A full description of the data used in this project can be found at

[The UCI Machine Learning Repository](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

The source data for this project can be found at

[Source Data](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)

Making Modifications to This Script
-----------------------------------

Once you have obtained and unzipped the source files, you will need to make one modification to the R file before you can process the data. Note that on line 8 of Run\_Analysis.R, you will set the path of the working directory to relect the location of the source files in your own directory.

Project Summary
---------------

The following are the steps done to create a Tidy Data

1.  Merging the training and the test sets to create one data set.
2.  Extracting only the measurements on the mean and standard deviation for each measurement.
3.  Using descriptive activity names to name the activities in the data set.
4.  Appropriately labeling the data set with descriptive activity names.
5.  Creating a second, independent tidy data set with the average of each variable for each activity and each subject.

Additional Information
----------------------

You can find additional information about the variables, data and transformations in the CodeBook.MD file.
