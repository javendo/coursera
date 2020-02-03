complete <- function(directory, id = 1:332) {
  ## 'directory' is a character vector of length 1 indicating
  ## the location of the CSV files

  ## 'id' is an integer vector indicating the monitor ID numbers
  ## to be used

  ## Return a data frame of the form:
  ## id nobs
  ## 1  117
  ## 2  1041
  ## ...
  ## where 'id' is the monitor ID number and 'nobs' is the
  ## number of complete cases

  table.all <- data.frame(id=numeric(), nobs=numeric())
  for (file.id in id) {
    file = sprintf("%s/%03d.csv", directory, file.id)
    table <- read.csv(file)
    table.length <- length(na.omit(table)$ID)
    table.counter <- data.frame(id=file.id, nobs=table.length)
    table.all <- rbind(table.all, table.counter)
    #table.na.omit <- na.omit(table)
    #if (length(table.na.omit$ID) > 0)
    #table.all <- rbind(table.all, aggregate(list(nobs=table.na.omit$ID), list(id=table.na.omit$ID), length))
  }
  invisible(table.all)
}

source("http://spark-public.s3.amazonaws.com/compdata/scripts/complete-test.R")
#complete.testscript()
