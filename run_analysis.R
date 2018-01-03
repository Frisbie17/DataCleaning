
setwd("C:/Users/1255049344/Desktop/Coursera")
library("data.table")
library("reshape2")

## Get Data:  Download the File
if (!file.exists("./data/UCIData")) {
  dir.create("./data/UCIData")
}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/UCIData/Dataset.zip")
dateDownloaded <- date()

# Unzip the Dataset
unzip("./data/UCIData/Dataset.zip", overwrite = TRUE,  junkpaths = TRUE, exdir = "./Data/UCIData", unzip = "internal",
      setTimes = FALSE)


#get the features list
features <- (read.table("./data/UCIData/features.txt")[,2])


#Get the activity lables
activitylabels <- read.table("./data/UCIData/activity_labels.txt")[,2]


#Get the Training data
ytrain <- read.table("./data/UCIData/y_train.txt")
xtrain <- read.table("./data/UCIData/x_train.txt")


#Get the Test Data
ytest <- read.table("./data/UCIData/y_test.txt")
xtest <- read.table("./data/UCIData/x_test.txt")


#Get the Subject Data
subjecttrain <- read.table("./data/UCIData/subject_train.txt")
subjecttest <- read.table("./data/UCIData/subject_test.txt")


merged_subject <- rbind(subjecttrain, subjecttest) #Merge Subject Ids
merged_activity <- rbind(ytrain, ytest) #Merge Activity Data
merged_labels <- rbind(xtrain, xtest) #merge Activity Types

names(merged_labels) <- features
names(merged_activity) <- c("activityID")
names(merged_subject) <- c('subjectID')

##Merges the training and the data sets.

remove(xtrain, ytrain,xtest, ytest, subjecttrain, subjecttest)


#Create variable Names
names(merged_subject) <- c("subjectID") #Add Subject ID Collum lable
names(merged_activity) <- c("activityId")

names(merged_labels) <- features
#Combine by collums
datamerge <- cbind(merged_subject, merged_activity)
datamerge<-cbind(datamerge, merged_labels)


remove(merged_activity, merged_labels, merged_subject, features)

datamerge[,2] <- activitylabels[datamerge[,1]]

remove (activitylabels)


##Extracts only the measurements on the mean and standard deviation for each measurement.
extractfeatures <-datamerge[,grepl("mean|std|subject|activityId",colnames(datamerge))]


# Write file
write.table(extractfeatures, "extractfeatures.txt", row.names = FALSE)

#used to fix variable names to ensure dcast vaule error due to ids
id_labels   <- c("subjectID", "activityId")
data_labels <- setdiff(colnames(extractfeatures), id_labels)
datafixed   <- melt(extractfeatures, id = id_labels, measure.vars = data_labels)

remove (data_labels, id_labels)

##From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

FinalDataTidy <- dcast(datafixed, subjectID + activityId ~ variable, mean)
write.table(FinalDataTidy, file = "./tidy_data.txt")
