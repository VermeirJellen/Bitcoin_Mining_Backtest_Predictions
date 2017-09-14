
source("config/Config.R")

BitcoinMiningBacktest(miner.price    = 2300,
                      fixed.cost     = 500,
                      miner.power    = 1247,
                      miner.hashrate = 13, 
                      nr.miners      = 5,
                      cost.kwh       = 0.05,
                      cost.var.daily = 0,
                      backtest.start = "2016-07-01",
                      backtest.end   = "2017-09-11")