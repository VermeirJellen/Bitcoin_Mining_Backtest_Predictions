############################################################################
### Load necessary packages and functions into memory                  #####
############################################################################
# if(!require(installr)) {install.packages("installr"); require(installr)}
# updateR()
packages <- c("timeSeries", "rrcov", "zoo", "xts", "car",
              "quadprog", "doParallel", "PerformanceAnalytics")
packages <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x)
    library(x, character.only = TRUE)
  }
})

Sys.setenv(TZ='UTC')

source("functions/FetchBTCInfo.R")
source("functions/BitcoinMiningBacktest.R")