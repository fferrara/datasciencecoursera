require(dplyr) # for summarize data

dataFile <- "samsungData.zip"

if (! file.exists(dataFile)){
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                destfile=dataFile)
}

unzip(dataFile) # will create "UCI HAR Dataset" directory

activityNames = as.vector(read.table("UCI HAR Dataset//activity_labels.txt", col.names=c("N", "NAME"))$NAME)
featureNames = as.vector(read.table("UCI HAR Dataset//features.txt", col.names=c("N", "NAME"))$NAME)

### Handling train&test data (features)
# Train data: 7352 samples, 561 features
trainData = read.table("UCI HAR Dataset/train//X_train.txt")
# Test data: 2947 samples, 561 features
testData = read.table("UCI HAR Dataset/test//X_test.txt")
# Merge: 10299 samples
allData = rbind(trainData, testData)
# Assign names to columns
names(allData) = featureNames
# Extracting features of interest
interestingFeatures = featureNames[grepl("mean()", featureNames, fixed=TRUE) | grepl("std()", featureNames, fixed=TRUE)]
allData = allData[, interestingFeatures]


### Handling train&test labels
# Train labels: 7352 labels
trainLabels = read.table("UCI HAR Dataset/train//y_train.txt", col.names=c("A"))
# Test labels: 2947 labels
testLabels = read.table("UCI HAR Dataset/test//y_test.txt", col.names=c("A"))
# Merge: 10299 labels
allLabels = rbind(trainLabels, testLabels)
# Factorize labels (from numbers to categories)
allLabels = factor(allLabels$A)
levels(allLabels) = activityNames

# Create the whole set
dataSet = cbind(allData, allLabels)
# Rename label column
names(dataSet)[ncol(dataSet)] = "ACTIVITY"

### Handling the subjects
trainSubjects = read.table("UCI HAR Dataset//train/subject_train.txt", col.names=c("S"))
testSubjects = read.table("UCI HAR Dataset//test/subject_test.txt", col.names=c("S"))
allSubjects = factor(rbind(trainSubjects, testSubjects)$S)
dataSet = cbind(dataSet, allSubjects)
# Rename subject column
names(dataSet)[ncol(dataSet)] = "SUBJECT"

### Using dplyr for compute summarizing values
grouping <- group_by(dataSet, ACTIVITY, SUBJECT)
summarizedSet <- summarise_each(grouping, funs(mean))
write.table(summarizedSet, file="result.txt", row.names=FALSE)