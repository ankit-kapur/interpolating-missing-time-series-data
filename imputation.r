df = read.csv("~/code/independent/datasets/combined_df_removedcolumns.csv", sep='\t')

data = df[8:dim(df)[2]]

# See the first couple of rows
head(data, 2)

# Install required libraries
install.packages("mice")
install.packages("VIM")

# Load the mice library
library(mice)
md.pattern(data)

# Plot a histogram to understand the missing data
aggr_plot <- aggr(data, col=c('navyblue','red'), numbers=TRUE, sortVars=TRUE, labels=names(data), cex.axis=.7, gap=3, ylab=c("Histogram of missing data","Pattern"))

# Plot the eGFR and FND_BPS values 
two_columns = data[c(1, dim(data)[2])]
marginplot(two_columns)

# Test whether the data is MCAR
out <- TestMCARNormality(data=data, imputation.number = 10))
library(MissMech)