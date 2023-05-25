library('dplyr')
library(data.table)

download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
              "UCI.zip")

unzip("UCI.ZIP")  

## read all data
trainx = read.table("UCI HAR Dataset/train/X_train.txt")
trainy = read.table("UCI HAR Dataset/train/y_train.txt")

testx = read.table("UCI HAR Dataset/test/X_test.txt")
testy = read.table("UCI HAR Dataset/test/y_test.txt")

subjecttrain = read.table("UCI HAR Dataset/train/subject_train.txt")
subjecttest = read.table("UCI HAR Dataset/test/subject_test.txt")

# Loading features
features = read.table("UCI HAR Dataset/features.txt")

# Loading activity table
activity_table = read.table("UCI HAR Dataset/activity_labels.txt")

selected_cols = grep("-(mean|std).*",features$V2)
selected_col_names = grep("-(mean|std).*",features$V2,value = TRUE) 

## 1 Append trainx and testx together
x = rbind(trainx,testx)

## 1 Append trainy and testy together
y = rbind(trainy,testy)
names(y) = c("Activity")
  

## 2 Filter out only mean and sd columns for each measurement
x <- x[,selected_cols]


## 3 Setting descriptive activity names
y$Activity = factor(y$Activity,levels = activity_table[,1], labels=activity_table[,2])


## 4 Appropriately labels the data set
selected_col_names = gsub("\\(\\)","",selected_col_names) 
names(x) = selected_col_names 


## Append subject train and test together
subject = rbind(subjecttrain,subjecttest)
names(subject) = c("Subject")

## Append all columns together
merged = cbind(subject,x,y)

# Converting to datatable
table = data.table(merged)

# 5 Creates a second, independent tidy data set with the average 
#    of each variable for each activity and each subject

# Melting table to convert columns to variables and values
meltedtable = melt(table, id.vars = c("Subject","Activity"))

# Cast the variables back to Columns by taking the mean value
cleanedtable = dcast(meltedtable,Subject+Activity~variable,mean)
write.table(cleanedtable,"./UCI HAR Dataset/tidydata.txt")


