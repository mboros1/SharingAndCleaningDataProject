
library(reshape2)

## Load data

train <- read.table("UCI HAR Dataset/train/X_train.txt")
test <- read.table("UCI HAR Dataset/test/X_test.txt")
ytrain <- read.table("UCI HAR Dataset/train/y_train.txt")
ytest <- read.table("UCI HAR Dataset/test/y_test.txt")
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt")
subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt")
features <- read.table("UCI HAR Dataset/features.txt")
activitylabels <- read.table("UCI HAR Dataset/activity_labels.txt")

## Combine the 'train' and 'test' data sets

TrainTestCombined <- rbind(train, test)
yCombined <- rbind(ytrain, ytest)
subjectcombined <- rbind(subjectTrain, subjectTest)

## Rename the columns in the Train, Test combined data set with their names from the 'features' file

names(TrainTestCombined) <- features[,2]

## Sort out only the columns whose variables are means and standard deviations.

MeansAndSDs <- grep(".*mean.*|.*std.*", features[,2])
TrainTestCombined <- TrainTestCombined[MeansAndSDs]

## Rename the columns to more user friendly variable names

featuresnames <- features[MeansAndSDs,2]
featuresnames <- gsub('-mean', 'Mean', featuresnames)
featuresnames <- gsub('-std', 'Std', featuresnames)
featuresnames <- gsub('[-()]', '', featuresnames)
names(TrainTestCombined) <- featuresnames
names(yCombined) <- c("ActivityLabelID")
names(subjectcombined) <- c("SubjectID")

## Create a new column that also gives the descriptive activity name

activities <- yCombined[[1]]

CombinedData <- cbind(activitylabels[,2][activities], subjectcombined, TrainTestCombined)
names(CombinedData) <- c("ActivityLabels", names(CombinedData[,2:81]))  ## Change the name of the newest column

# Melt and cast the data in a form suitable for the final "tidy data" table.

CombinedDataMelted <- melt(CombinedData, id = c("SubjectID", "ActivityLabels"))
CombinedDataMean <- dcast(CombinedDataMelted, SubjectID + ActivityLabels ~ variable, mean)

write.table(CombinedDataMean, "tidy.txt", row.names = FALSE, quote = FALSE)
