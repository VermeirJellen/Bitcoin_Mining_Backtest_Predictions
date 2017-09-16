BitcoinMiningBacktest <- function(miner.price    = 2300,
                                  fixed.cost     = 500,
                                  miner.power    = 1247,
                                  miner.hashrate = 13, 
                                  nr.miners      = 5,
                                  cost.kwh       = 0.05,
                                  cost.var.daily = 0,
                                  backtest.start = "2016-07-01",
                                  forward.mode                 = FALSE,
                                  bitcoin.price.predictions    = NULL,
                                  network.revenue.predictions  = NULL,
                                  network.hashrate.predictions = NULL
                                  ){
  
  if (!forward.mode){
    btc.price <- FetchBTCInfo(param           = "market-price",   
                              data.identifier = "btc.close", 
                              date.start      = backtest.start)
  }
  else {
    btc.price <- bitcoin.price.predictions
  }
  
  date.range <- index(btc.price)
  
  
  if (!forward.mode){
    # Total value of coinbase block rewards and transaction fees paid to miners.
    mining.revenue.usd <- FetchBTCInfo(param           = "miners-revenue", 
                                       data.identifier = "mining.revenue",
                                       date.start      = backtest.start)
  }
  else {
    mining.revenue.usd <- network.revenue.predictions
  }
  # Revenue expressed in btc
  mining.revenue.btc <- mining.revenue.usd / btc.price
  
  ######################################
  #### CALCULATE USD COSTS #############
  ######################################
  nr.days <- length(date.range)
  initial.investment  <- nr.miners * miner.price + fixed.cost
  print(paste("Fixed Initial Investment: ", initial.investment, "USD", sep=""))
  initial.investment  <- xts(matrix(rep(initial.investment, nr.days), ncol=1),
                             order.by = date.range)
  
  daily.electricity.cost <- (miner.power / 1000) * cost.kwh * 24 * nr.miners
  print(paste("Daily Electricity Cost: ", daily.electricity.cost, "USD", sep=""))
  cumulative.electricity.cost <- xts(matrix(cumsum(rep(daily.electricity.cost, nr.days)), ncol=1),
                                     order.by = date.range)
  
  print(paste("Additional Daily Costs: ", cost.var.daily, "USD", sep=""))
  cumulative.operational.cost <- xts(matrix(cumsum(rep(cost.var.daily, nr.days)), ncol=1),
                                     order.by = date.range)
  
  variable.cost.usd <- cumulative.electricity.cost + cumulative.operational.cost
  total.cost.usd    <- initial.investment + variable.cost.usd
  
  if (!forward.mode){
    # The estimated number of tera hashes per second the Bitcoin network is performing.
    hashrate.total <- FetchBTCInfo(param           = "hash-rate", 
                                   data.identifier = "mining.hashrate",
                                   date.start      = backtest.start)
  }
  else {
    hashrate.total <- network.hashrate.predictions
  }
  
  hashrate.initial <- nr.miners * miner.hashrate
  
  # Our percentage ownership of the hashrate over time (scales with difficulty)
  hashrate.percentage <- hashrate.initial / hashrate.total * 100
  # calculate 
  
  # if ratio is small, equals good time to buy equipment? (expensive price)
  price.hashrate.ratio <- btc.price / hashrate.total
  
  network.hashrate.start <- as.numeric(head(hashrate.total, 1))
  network.hashrate.end   <- as.numeric(tail(hashrate.total, 1))
  ownership.start <- as.numeric(head(hashrate.percentage, 1))
  ownership.end   <- as.numeric(tail(hashrate.percentage, 1))
  
  print(paste("Initial Hashrate of ", hashrate.initial, "TH/s represents ", 
              ownership.start, "% of the total network hashrate (", network.hashrate.start,
              "TH/s) on ", head(date.range, 1), sep=""))
  
  print(paste("Initial Hashrate of ", hashrate.initial, "TH/s represents ", 
              ownership.end, "% of the total network hashrate (", network.hashrate.end,
              "TH/s) on ", tail(date.range, 1), sep=""))
  
  plot(date.range, btc.price, lty=1, type='l', 
       xlab = "Time", ylab="USD",
       main = "Price Bitcoin")
  plot(date.range, hashrate.total, 
       xlab = "Time", ylab="TH/sec",
       lty=1, type='l', main = "Total Network Hashrate")
  plot(date.range, price.hashrate.ratio,
       xlab = "Time", ylab="Price / Hashrate ratio",
       lty=1, type='l', main = "BTC Price to Hashrate Ratio")
  plot(date.range, hashrate.percentage, 
       xlab = "Time", ylab="Percentage",
       lty=1, type='l', main = "Personal hashrate Ownership (%)")
  
  daily.revenue.usd     <- hashrate.percentage/100 * mining.revenue.usd
  total.revenue.usd.sum <- xts(matrix(cumsum(daily.revenue.usd), ncol=1),
                               order.by = date.range)

  plot(date.range, mining.revenue.usd, 
       xlab = "Time", ylab="USD",
       lty=1, type='l', main = "Daily Network Revenue (USD)")
  plot(date.range, daily.revenue.usd, 
       xlab = "Time", ylab="USD",
       lty=1, type='l', main = "Daily Personal Revenue (USD)")
  # plot(date.range, total.revenue.usd.sum, main = "Cumulative Personal Revenue (USD)", lty=3)
  
  
  ##################################################################
  #### SELL BTC AT MARKET - ASSUME DAILY SELL  #####################
  ##################################################################
  plot(date.range, total.cost.usd, lty=1, type='l',
       main = "Mine and Sell (daily)", col = "red",
       xlab = "Time", ylab = "USD",
       ylim = c(0, max(total.cost.usd, total.revenue.usd.sum)))
  lines(date.range, total.revenue.usd.sum, col = "Green", lty=1, type='l', lwd=2)
  legend("topleft", legend = c("Cumulative Expenses", "Cumulative Revenue"), 
         lty=c(1, 1), lwd=c(2,2), col=c("red", "green"))
  
  daily.revenue.btc     <- hashrate.percentage/100 * mining.revenue.btc
  total.revenue.btc.sum <- xts(matrix(cumsum(daily.revenue.btc), ncol=1),
                               order.by = date.range)
  
  roi.nr.days <- head(which(total.revenue.usd.sum > total.cost.usd), 1)
  roi.date    <- date.range[roi.nr.days]
  print("Mine and sell strategy - statistics:")
  if(length(roi.date) > 0){
    print(paste("ROI reached on", roi.date, "after", roi.nr.days, "days."))
  }
  else {
    print("ROI not reached during time interval..")
    print("")
  }
  
  end.date <- tail(date.range, 1)
  end.cost <- round(as.numeric(tail(total.cost.usd, 1)), 2)
  end.revenue <- round(as.numeric(tail(total.revenue.usd.sum, 1)), 2)
  print(paste("Total Expenditures on ", end.date, ": ", end.cost, "USD", sep=""))
  print(paste("Total Revenue on ", end.date, ": ", end.revenue, "USD", sep=""))
  print(paste("Total Profit on ", end.date, ": ", end.revenue - end.cost, 
              "USD after ", length(date.range), " days.", sep=""))
  
  ####################################
  ### Buy and Hold - BTC ANALYSIS ####
  ####################################

  initial.investment.usd    <- nr.miners * miner.price + fixed.cost
  initial.bitcoins          <- initial.investment.usd / as.numeric(head(btc.price, 1))
  # Use the varible cost to buy bitcoin at market
  daily.bitcoins            <- (daily.electricity.cost + cost.var.daily) / btc.price
  cumulative.daily.bitcoins <- cumsum(daily.bitcoins)
  buy.and.hold.btc          <- initial.bitcoins + cumulative.daily.bitcoins
  
  
  plot(date.range, buy.and.hold.btc, col = "red", lty=1, type='l',
       xlab = "Time", ylab = "BTC",
       main = "Buy and Hold VS Mine and Hold",
       ylim = c(0, max(buy.and.hold.btc, total.revenue.btc.sum)))
  lines(date.range, as.numeric(total.revenue.btc.sum), col = "Green", lty=1, type='l', lwd=2)
  legend("topleft", legend = c("Buy and Hold", "Mine and Hold"), 
         lty=c(1, 1), lwd=c(2,2), col=c("red", "green"))
  
  ############################
  ### CALCULATE PROFIT ETC ###
  ############################
  buy.hold.end <- tail(buy.and.hold.btc, 1)
  mining.end   <- tail(total.revenue.btc.sum, 1)
  date.end     <- tail(date.range, 1)
  price.end    <- tail(btc.price, 1)
  cost.end     <- tail(total.cost.usd, 1)
  
  buy.hold.usd    <- buy.hold.end * price.end
    
  mining.end.usd <- mining.end * price.end 
  
  print("Buy and Hold versus Mine and Hold")
  print("For fair comparison, buy and hold strategy is performed as follows:")
  print(paste("buy ", round(initial.bitcoins, 4), "BTC using ", 
              initial.investment.usd, "USD on ", backtest.start, sep=""))
  print("Use daily Variable mining Costs to buy more BTC at market price")
  
  print("")
  print(paste("Total Expenditures over time interval: ", 
              round(as.numeric(cost.end), 2), "USD", sep=""))
  print("")
  print("Buy and Hold:")
  print(paste("Selling", round(as.numeric(buy.hold.end), 4), "coins at a price of", 
              round(as.numeric(price.end), 2), "USD on", date.end, "for", 
              round(as.numeric(buy.hold.usd),2), "USD"))
  print(paste("Total Profit:", round(as.numeric(buy.hold.usd - cost.end), 2), "USD"))
  
  print("")
  print("Mine and Hold:")
  print(paste("Selling", round(as.numeric(mining.end), 4), "coins at a price of", 
              round(as.numeric(price.end), 2), "USD on", date.end, "for", 
              round(as.numeric(mining.end.usd),2), "USD"))
  print(paste("Total Profit:", round(as.numeric(mining.end.usd - cost.end), 2), "USD"))
  
  print("")
  btc.profit <- mining.end - buy.hold.end
  print(paste("Mine and hold versus Buy and hold - Additional profit: ", 
              round(as.numeric(btc.profit * tail(btc.price, 1)), 2), "USD", sep=""))
}
