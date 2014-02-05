module CryptsyClient
	class Market

		attr_accessor :market_id,         :label,
             			:primary_coin,      :secondary_coin,
             			:primary_coin_name, :secondary_coin_name,
             			:last_trade

		def initialize(cryptsy_data)
			@market_id = cryptsy_data.delete(:market_id)
			@market_id = @market_id.to_i
			raise 'At least market_id required' if @market_id.nil?
			update(cryptsy_data)
	  end

		def trades
			(@trades.nil? || @trades.empty?) ? recent_trades : trades
		end

		def balances
		  CryptsyClient.balances.select{|coin, balance| coin == primary_coin || coin == secondary_coin}
		end

		def primary_coin_balance
			balances[primary_coin]
		end

		def secondary_coin_balance
			balances[secondary_coin]
		end

		def depth
			response = CryptsyClient.connection.call(:depth)

			if response.success?
				response
			else
			  {:buy => [], :sell => []}
			end
		end

		def orders(only=nil)
		  active_orders = CryptsyClient.connection.call(:marketorders, market_id)
			unless active_orders.success?
			  return {:sell=>[], :buy => []}
			end
			response = {}
			unless only.eql?(:buy)
				response[:sell] = active_orders[:sellorders].collect{|so| SellOrder.new(market_id, so[:price], so[:quantity], so[:total])}
			end
			unless only.eql?(:sell)
				response[:buy] = active_orders[:buyorders].collect{|so| BuyOrder.new(market_id, so[:price], so[:quantity], so[:total])}
			end
			response
		end

		def sell_orders
			orders(:sell)[:sell]
		end

		def buy_orders
			orders(:buy)[:buy]
		end

		def buy!(price, quantity)
			order = BuyOrder.new(market_id, price, quantity)
			order.execute!
			order
		end

		def sell!(price, quantity)
			order = BuyOrder.new(market_id, price, quantity)
			order.execute!
			order
		end

		def recent_trades
		 	CryptsyClient.connection.call(:markettrades, market_id)["return"].collect{|td| Trade.new(market_id, td)}
		end

		def update(cryptsy_data = {})
			if cryptsy_data.keys.empty?
				cryptsy_data = CryptsyClient.connection.call(:marketdata, market_id)

				cryptsy_data = cryptsy_data[:markets].first.last
			end

			if cryptsy_data
				@primary_coin        ||= cryptsy_data[:primarycode] || cryptsy_data[:primary_currency_code]
				@secondary_coin      ||= cryptsy_data[:secondarycode] || cryptsy_data[:secondary_currency_code]
				@label               ||= cryptsy_data[:label]
				@last_trade            = cryptsy_data[:lasttradeprice] || cryptsy_data[:last_trade]
				@primary_coin_name   ||= cryptsy_data[:primarycoinname] || cryptsy_data[:primary_currency_name]
				@secondary_coin_name ||= cryptsy_data[:secondarycoinname] || cryptsy_data[:secondary_currency_name]
				if cryptsy_data[:recenttrades]
			    @trades = cryptsy_data[:recenttrades].collect{|rt| Trade.new(market_id, rt)}
				end
				true
			else
			  false
		  end
		end
	end
end
