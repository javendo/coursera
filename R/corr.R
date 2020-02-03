corr <- function(directory, threshold = 0) {
  ## 'directory' is a character vector of length 1 indicating
  ## the location of the CSV files

  ## 'threshold' is a numeric vector of length 1 indicating the
  ## number of completely observed observations (on all
  ## variables) required to compute the correlation between
  ## nitrate and sulfate; the default is 0

  vector.cor = vector()
  for (f in list.files(path = directory)) {
    file = sprintf("%s/%s", directory, f)
    table <- read.csv(file)
    table.na.omit = na.omit(table)
    table.length <- length(table.na.omit$ID)
    if (table.length > threshold)
      vector.cor = c(vector.cor, cor(table.na.omit$nitrate, table.na.omit$sulfate))
  }
  invisible(vector.cor)
}

source("http://spark-public.s3.amazonaws.com/compdata/scripts/corr-test.R")
#corr.testscript()
