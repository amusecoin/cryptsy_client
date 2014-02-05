module CryptsyClient
  class MarketList < Hash

    def initialize(*args)
      super *args
      @market_ids = {}
      update
    end

    def find_by_id(id)
      self.fetch(@market_ids[id.to_i], nil)
    end

    def update
      response = CryptsyClient.connection.call(:getmarkets)
      if response.success?
        response.each do |market|
          self[market[:label]] = Market.new(market)
          @market_ids[market[:market_id]] = market[:label]
        end
        true
      else
        false
      end
    end
  end
end
