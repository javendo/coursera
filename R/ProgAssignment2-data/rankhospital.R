rankhospital <- function(state, outcome, num="best") {
  options(warn=-1)
  outcome.index.matrix = matrix(c(11, 17, 23), ncol=3)
  colnames(outcome.index.matrix) <- c("heart attack", "heart failure", "pneumonia")
  if (!(outcome %in% colnames(outcome.index.matrix))) stop("invalid outcome")
  outcome.index <- outcome.index.matrix[, outcome]
  outcome.data <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
  outcome.data[, outcome.index] <- as.numeric(outcome.data[, outcome.index])
  outcome.data <- outcome.data[complete.cases(outcome.data[, outcome.index]), ]
  outcome.filtered.by.state <- subset(outcome.data, State == state)
  outcome.filtered.by.state.length = length(outcome.filtered.by.state[, outcome.index])
  if (outcome.filtered.by.state.length == 0) stop("invalid state")
  if (is.numeric(num)) {
    ranking.index <- num
  }
  else {
    ranking.index.matrix = matrix(c(1, outcome.filtered.by.state.length), ncol=2)
    colnames(ranking.index.matrix) <- c("best", "worst")
    if (!(num %in% colnames(ranking.index.matrix))) {
      ranking.index <- outcome.filtered.by.state.length + 1
    }
    else {
      ranking.index <- ranking.index.matrix[, num]
    }
  }
  outcome.filtered.by.state.ordered <- outcome.filtered.by.state[order(outcome.filtered.by.state[, outcome.index], outcome.filtered.by.state$Hospital.Name), ]
  outcome.filtered.by.state.ordered$Hospital.Name[ranking.index]
}
