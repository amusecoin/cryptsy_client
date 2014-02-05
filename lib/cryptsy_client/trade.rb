require 'time'

module CryptsyClient
	class Trade
		attr_accessor :market_id, :trade_id, :time, :price, :quantity, :total

		def initialize(market_id, trade_data)
			@market_id = market_id.to_i
			@trade_id  = trade_data[:id] || trade_data[:trade_id]
			@time      = Time.parse("#{trade_data[:time] || trade_data[:datetime]} #{CryptsyClient.server_time_zone}")
			@price     = trade_data[:price] || trade_data[:tradeprice]
			@quantity  = trade_data[:quantity]
			@total     = trade_data[:total]
		end

		def market
			@market ||= CryptsyClient.market_list.find_by_id(market_id)
		end

	end
end
