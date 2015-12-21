# Read the combined dataframe
df = read.csv("~/code/independent/outputs/combined_df_normalized.csv", sep='\t')

# Get the data columns
data = df[6:dim(df)[2]]

# See the first couple of rows
head(data, 2)

# Install required libraries
install.packages("mice")
install.packages("VIM")

# Plot a histogram to understand the missing data
library(VIM)
md.pattern(data)
aggr_plot <- aggr(data, col=c('navyblue','red'), numbers=TRUE, sortVars=TRUE, labels=names(data), cex.axis=.7, gap=3, ylab=c("Histogram of missing data","Pattern"))

# Plot the eGFR and FND_BPS values 
two_columns = data[c(1, dim(data)[2])]
marginplot(two_columns)

# Test whether the data is MCAR
# out <- TestMCARNormality(data=data, imputation.number = 10))
# library(MissMech)
library(mice)
miceImputedData <- mice(data,m=3,maxit=1,seed=500)

# View a summary of the imputed data
summary(miceImputedData)

# Complete the dataset using the imputed values
completedData = complete(miceImputedData, 1)
completedData$pid <- df$pid
completedData$timestamp <- df$timestamp
completedData$gender <- df$gender
completedData$birthyear <- df$birthyear
completedData$age <- df$age

# Change the ordering of the columns
combinedData <- completedData[c(17:21, 1:16)]

# Write completed dataset to CSV
write.csv(file="~/code/mice_imputed_m3_combined.csv", x=combinedData)