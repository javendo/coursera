outcome <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
names(outcome)
outcome[, 11] <- as.numeric(outcome[, 11])
outcome[, 17] <- as.numeric(outcome[, 17])
outcome[, 23] <- as.numeric(outcome[, 23])
par(mfrow = c(3, 1))
common.range <- range(c(outcome[, 11], outcome[, 17], outcome[, 23]), na.rm=TRUE)
common.range
par(mfrow = c(1, 3))
median.heart.attack <- median(outcome[, 11], na.rm=TRUE)
hist(outcome[, 11], main=bquote("Heart Atack(" ~ bar(X) ~ "=" ~ .(median.heart.attack) ~ ")"), xlab="30-day Death Rate", xlim=common.range, prob=TRUE)
abline(v=median.heart.attack)
lines(density(outcome[, 11], na.rm=TRUE, bw=0.4))
median.heart.failure <- median(outcome[, 17], na.rm=TRUE)
hist(outcome[, 17], main=bquote("Heart Failure(" ~ bar(X) ~ "=" ~ .(median.heart.failure) ~ ")"), xlab="30-day Death Rate", xlim=common.range, prob=TRUE)
abline(v=median.heart.failure)
lines(density(outcome[, 17], na.rm=TRUE, bw=0.4))
median.pneumonia <- median(outcome[, 23], na.rm=TRUE)
hist(outcome[, 23], main=bquote("Pneumonia (" ~ bar(X) ~ "=" ~.(median.pneumonia) ~ ")"), xlab="30-day Death Rate", xlim=common.range, prob=TRUE)
abline(v=median.pneumonia)
lines(density(outcome[, 23], na.rm=TRUE, bw=0.4))



outcome <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
state.table <- table(outcome$State)
state.table.more.than.20 <- state.table[state.table >= 20]
outcome.more.than.20 <- subset(outcome, State %in% names(state.table.more.than.20))
par(mfrow = c(1, 1))
death <- as.numeric(outcome.more.than.20[, 11])
state <- outcome.more.than.20$State
state.median <- reorder(state, death, median, na.rm=TRUE)
par(mar=c(8, 3, 3, 3), mgp=c(6, 1, 0))
boxplot(death ~ state.median, xaxt="n", las=2, main="Heart Attack 30-day Death Rate by State", xlab="30-day Death Rate")
x.labels <- paste(names(table(state.median)), "(", table(state.median), ")")
axis(1, 1:length(x.labels), labels=x.labels, las=2, cex.axis=0.8)




hospital <- read.csv("hospital-data.csv", colClasses = "character")
outcome.hospital <- merge(outcome, hospital, by = "Provider.Number")
death <- as.numeric(outcome.hospital[, 11]) ## Heart attack outcome
npatient <- as.numeric(outcome.hospital[, 15])
owner <- factor(outcome.hospital$Hospital.Ownership)
library(lattice)
xyplot(death ~ npatient | owner, main="Heart Attack 30-day Death Rate by Ownership", ylab="30-day Death Rate", xlab="Number of Patients Seen",
       panel = function(x, y, ...) {
         panel.xyplot(x, y, ...)
         panel.lmline(x, y, col="black", ...)
       })



source("best.R")
best("TX", "heart attack")
best("TX", "heart failure")
best("MD", "heart attack")
best("MD", "pneumonia")
best("BB", "heart attack")
best("NY", "hert attack")



source("rankhospital.R")
rankhospital("TX", "heart failure", 4)
rankhospital("MD", "heart attack", "worst")
rankhospital("MN", "heart attack", 5000)
rankhospital("MN", "heart attack", "zequinha")



source("rankall.R")
head(rankall("heart attack", 20), 10)
tail(rankall("pneumonia", "worst"), 3)
tail(rankall("heart failure"), 10)
