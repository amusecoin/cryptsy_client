require 'cryptsy/api'

module CryptsyClient
  # Your code goes here...

	def self.configure(&block)
		yield config
	end

	def self.config
		@config ||= Configuration.new
	end

	def self.connection
		@connection ||= Connection.new(@config.public_key, @config.private_key)
	end

	def self.market_list
		unless @market_list
		  @market_list = MarketList.new
			@market_list.update
		end
		@market_list
	end

	def self.server_time_zone
		@server_time_zone ||= connection.call(:getinfo).fetch(:servertimezone, nil)
	end

	def self.server_time
		if @server_time_obtained && Time.now.to_i - @server_time_obtained > 3
			@server_time_obtained = nil
		elsif @server_time_obtained
			return @server_time
		end
		response = connection.call(:getinfo)
		@server_time_zone = response[:servertimezone]
		@server_time = Time.parse("#{response[:serverdatetime]} #{@server_time_zone}")
		@server_time_obtained = Time.now.to_i
		@server_time
	end

	def self.buy_fee_multiplier
		@server_buy_multiplier ||= connection.call(:calculatefees, "Buy", 1, 1).fetch(:net, 0.997).to_f
	end

	def self.sell_fee_multiplier
		@server_sell_multiplioer ||= connection.call(:calculatefees, "Sell", 1, 1).fetch(:net, 1.002).to_f
	end

	def self.balances
		response = CryptsyClient.connection.call(:getinfo)
		if response.success?
			response[:balances_available]
		else
			{}
		end
	end

	def self.market(market_id_or_label)
		if market_id_or_label.kind_of?(String)
			CryptsyClient.market_list[market_id_or_label]
		else
			CryptsyClient::Market.new(:market_id => market_id_or_label)
		end
	end

end

Dir[File.expand_path('../cryptsy_client/*.rb', __FILE__)].each {|path| require path}

