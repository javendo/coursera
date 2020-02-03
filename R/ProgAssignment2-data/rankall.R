source("rankhospital.R")

rankall <- function(outcome, num="best") {
  outcome.data <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
  hospitals <- c()
  states <- c()
  for (i in names(table(outcome.data$State))) {
    states <- append(states, i)
    hospitals <- append(hospitals, rankhospital(i, outcome, num))
  }
  data.frame(hospital=hospitals, state=states)
}
