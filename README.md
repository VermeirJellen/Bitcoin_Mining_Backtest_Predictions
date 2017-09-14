Bitcoin Mining - Backtest and Predictions
================

-   Bitcoin mining - historical backtest example.
-   Bitcoin mining - profitabiliy predictions, based on Bitcoin price and Network hashrate trend regressions (todo).

More info will be added soon..

Example - 5 Bitmain ASIC miners
===============================

Assumptions:

-   Five antminer S9 ASIC Miners bought from the bitmain website at 2300 USD per miner in july 2016.
-   Energy efficient mining in Iceland at 5 cents per kwh.
-   Initial 500USD operational expense (shipping, setup costs, etc..).

Relevant network data and mining results are illustrated below (more info to be added soon..)

``` r
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
```

    ## [1] "Fixed Initial Investment: 12000USD"
    ## [1] "Daily Electricity Cost: 7.482USD"
    ## [1] "Additional Daily Costs: 0USD"
    ## [1] "Initial Hashrate of 65TH/s represents 0.00397631401502343% of the total network hashrate (1634679.75TH/s) on 2016-07-01"
    ## [1] "Initial Hashrate of 65TH/s represents 0.000745832821472093% of the total network hashrate (8715089.78TH/s) on 2017-09-13"

![](README_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-1-1.png)![](README_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-1-2.png)![](README_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-1-3.png)![](README_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-1-4.png)![](README_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-1-5.png)![](README_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-1-6.png)![](README_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-1-7.png)

    ## [1] "BUY AND HOLD - Buying versus Mining"
    ## [1] "buy 17.773BTC using 12000USD on 2016-07-01"
    ## [1] "Use daily Variable mining Costs to buy more BTC at market price"

![](README_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-1-8.png)

    ## [1] "BTC profit: 21.5369 - 21.0847 = 0.4522"
    ## [1] "USD mining profit in addition to price appreciation: 1791.46USD"

Predictions
===========

todo..

Donations
---------

If you find this software useful and/or you would like to see additional extensions, feel free to donate some crypto:

-   BTC: 1QHtZLZ15Cmj4FPr5h5exDjYciBDhh7mzA
-   LTC: LhKf6MQ7LY1k8YMaAq9z3APz8kVyFX3L2M
-   ETH: 0x8E44D7C96896f2e0Cd5a6CC1A2e6a3716B85B479
-   DASH: Xvicgp3ga3sczHtLqt3ekt7fQ62G9KaKNB

Or preferably, donate some of my favorite coins :)

-   GAME: GMxcsDAaHCBkLnN42Fs9Dy1fpDiLNxSKX1
-   WAVES: 3PQ8KFdw2nWxQATsXQj8NJvSa1VhBcKePaf

Licensing
---------

Copyright 2017 Essential Data Science Consulting ltd. ([EssentialQuant.com](http://essentialquant.com "EssentialQuant") / <jellenvermeir@essentialquant.com>). This software is copyrighted under the MIT license: View added [LICENSE](./LICENSE) file.
