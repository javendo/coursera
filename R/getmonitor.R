getmonitor <- function(id, directory, summarize = FALSE) {
  ## 'id' is a vector of length 1 indicating the monitor ID
  ## number. The user can specify 'id' as either an integer, a
  ## character, or a numeric.

  ## 'directory' is a character vector of length 1 indicating
  ## the location of the CSV files

  ## 'summarize' is a logical indicating whether a summary of
  ## the data should be printed to the console; the default is
  ## FALSE

  filename <- c(0, 0, 0, strsplit(as.character(id), "")[[1]])
  filename <- paste(filename[length(filename):1][1:3][3:1], collapse="")
  file <- paste(directory, "/", filename, ".csv", sep="")
  table <- read.csv(file)
  if (summarize)
    print(summary(table))
  invisible(table)
}

source("http://spark-public.s3.amazonaws.com/compdata/scripts/getmonitor-test.R")
#getmonitor.testscript()
