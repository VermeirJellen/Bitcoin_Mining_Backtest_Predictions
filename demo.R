source("config/Config.R")

################################################
############ BACKTEST ##########################
################################################
BitcoinMiningBacktest(miner.price    = 2300,
                      fixed.cost     = 500,
                      miner.power    = 1247,
                      miner.hashrate = 13, 
                      nr.miners      = 5,
                      cost.kwh       = 0.05,
                      cost.var.daily = 0,
                      backtest.start = "2016-07-01")



################################################
########### FORWARD TEST #######################
################################################
date.start <- "2011-01-01"
btc.price <- FetchBTCInfo(param           = "market-price",   
                          data.identifier = "btc.close", 
                          date.start      = date.start)

btc.predictions <- SimpleLogTrendRegression(data = btc.price, 
                                            data.identifier = "BTC-price", 
                                            regression.type = "exponential",
                                            data.frequency  = "daily",
                                            nr.future       = 500, 
                                            plot.2sd.log    = TRUE, 
                                            plot.2sd.levels = FALSE)

## Total network mining revenue (coinbase + transaction) - Exponential regression.
mining.revenue.usd <- FetchBTCInfo(param           = "miners-revenue", 
                                   data.identifier = "mining.revenue",
                                   date.start      = date.start)

revenue.predictions <- SimpleLogTrendRegression(data = mining.revenue.usd, 
                                            data.identifier = "Mining.Revenue", 
                                            regression.type = "exponential",
                                            data.frequency  = "daily",
                                            nr.future       = 500, 
                                            plot.2sd.log    = TRUE, 
                                            plot.2sd.levels = FALSE)

# Hashrate trend predictions (Loess, degree = 1)
hashrate.total <- FetchBTCInfo(param           = "hash-rate", 
                               data.identifier = "mining.hashrate",
                               date.start      = date.start)

hashrate.predictions <- SimpleLogTrendRegression(data = hashrate.total, 
                                                 data.identifier = "Network Hashrate",
                                                 regression.type = "loess",
                                                 data.frequency  = "daily",
                                                 loess.degree    = 1,
                                                 nr.future       = 500, 
                                                 plot.2sd.log    = TRUE, 
                                                 plot.2sd.levels = FALSE)

BitcoinMiningBacktest(miner.price     = 1280,
                      fixed.cost      = 500,
                      miner.power     = 1247,
                      miner.hashrate  = 13,
                      nr.miners       = 5,
                      cost.kwh        = 0.05,
                      cost.var.daily  = 0,
                      forward.mode    = TRUE,
                      bitcoin.price.predictions   = btc.predictions$level.trend,
                      network.revenue.predictions = revenue.predictions$level.trend,
                      network.hashrate.predictions = hashrate.predictions$level.trend)
