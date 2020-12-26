## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(reshape2)
library(dplyr)

#set wd
setwd("C:/Users/nojus/OneDrive/Desktop/Data analyst/coursera/Get clean data course/course2/Final_project")

#get file names
list.files("./UCI HAR Dataset")

#Load data
activity_labels   <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
features          <- read.table("./UCI HAR Dataset/features.txt")[,2]

#get only mean and SD
extracted_features <- grepl("mean|std", features)


########## TEST DATA ###############


#load test data
X_test        <- read.table("./UCI HAR Dataset/test/X_test.txt")
Y_test        <- read.table("./UCI HAR Dataset/test/Y_test.txt")
subject_test  <- read.table("./UCI HAR Dataset/test/subject_test.txt")

#change column names
names(X_test) = features

#get the needed (mean,std) columns
X_test = X_test[, extracted_features]

#Match IDs with activity names
Y_test[,2] = activity_labels[Y_test[,1]]
names(Y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

#append x and y
test_data <- cbind(subject_test, Y_test, X_test)



####### TRAIN DATA ##########


# Load and process X_train & y_train data.
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
Y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(X_train) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
X_train = X_train[,extracted_features]

#Activity data
Y_train[,2] = activity_labels[Y_train[,1]]
names(Y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

#append x and y
train_data <- cbind(subject_train, Y_train, X_train)


########## MERGE ################

data <- rbind(train_data, test_data)

id_labels <- c("subject", "Activity_ID", "Activity_Label")
data_labels  <- setdiff(colnames(data), id_labels)
melt_data <- melt(data, id = id_labels, measure.vars = data_labels)

tidy_data = dcast(melt_data, subject + Activity_Label ~ variable, mean)

## different table layout
# tidy_data 2 <- melt_data %>%
#                 group_by(subject, Activity_Label, variable) %>%
#                 summarize("value" = mean(value))

write.table(tidy_data, file = "./tidy_data.txt")
