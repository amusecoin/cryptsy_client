# CryptsyClient

Work in progress! Master or any other branch for that matter might not be in a working state at all.

Creating a wrapper for nbarthel/cryptsy-api

## Getting started

The basic stuff, gem 'cryptsy_client', github: 'kke/cryptsy_client' into gemfile and so on.

Usage:

    CryptsyClient.configure do |config|
      config.public_key = 'XYZXYZXYZ'
      config.private_key = 'XXYYZZ'
    end

    market = CryptsyClient.market(141)
    market = CryptsyClient.market_list["42/BTC"]
    market.last_trade
    market.buy!(10000.0, 10.0)
    market.primary_coin_balance
    b = BuyOrder.new(market_id, price, amount)
    b.execute!
    b.trades
    b.cancel!

Stuff like that. Not ready at all, but the above examples should already work. Want to participate? Just /msg kke on freenode.
