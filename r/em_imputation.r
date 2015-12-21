library(e1071)
 
# Read the combined dataframe
raw  = read.csv("~/code/independent/outputs/combined_df_normalized.csv", sep='\t')
 
var(na.omit(raw) )
var(raw.imputed)
 
EMalg <- function(x, tol=.001){
missvals <- is.na(x)
new.impute<-x
old.impute <- x
count.iter <- 1
reach.tol <- 0
sig <- as.matrix(var(na.exclude(x)))
mean.vec <- as.matrix(apply(na.exclude(x),2,mean))
 
while(reach.tol != 1) {
for(i in 1:nrow(x)) {
pick.miss <-( c( missvals[i,]) )
if ( sum(pick.miss) != 0 ) {
inv.S <- solve(sig[!pick.miss,!pick.miss]) # we need the inverse of the covariance
 
# Run the EM
new.impute[i,pick.miss] <- mean.vec[pick.miss] +
sig[pick.miss,!pick.miss] %*%
inv.S %*%
(t(new.impute[i,!pick.miss])- t(t(mean.vec[!pick.miss])))
}
}
 
sig <- var((new.impute))
mean.vec <- as.matrix(apply(new.impute,2,mean))
 
if(count.iter > 1){ # we don't want this to run on the first iteration or else if fails
for(l in 1:nrow(new.impute)){
for(m in 1:ncol(new.impute)){
if( abs((old.impute[l,m]-new.impute[l,m])) > tol ) {
reach.tol < - 0
} else {
reach.tol <- 1
}
}
}
}
 
count.iter <- count.iter+1 # used for debugging purposes to ensure process it iterating properly
old.impute <- new.impute
}
 
return(new.impute)
}
raw.imputed <- EMalg(raw, tol=.0001)
plot(raw.imputed[,1], raw.imputed[,2], pch=16, main="Scatterplot of Missing Data",
sub="Missing Values in Red", xlab="X",ylab="Y")
 
# overlay the imputed values on the plot
 
plot.imputed <- raw.imputed[
row.names(
subset(raw, is.na( raw[,2] ) | is.na( raw[,3]) )
),]
points(plot.imputed[,2],plot.imputed[,3], pch=16, col='red')


 