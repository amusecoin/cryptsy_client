module CryptsyClient
  class Order
    attr_accessor :market_id, :price, :quantity, :total, :order_id, :error

    def initialize(market_id, price, quantity, total=nil)
      @market_id = market_id.to_i
      @order_id  = nil
      @error     = nil
      @price     = price.to_f
      @quantity  = quantity.to_f
      @total = (total || price * quantity).to_f
    end

    def market
      @market ||= CryptsyClient.market_list.find_by_id(market_id)
    end

    def exist?
      raise "Only available for own orders" if order_id.nil?
      !CryptsyClient.connection.call(:myorders, market_id).find{|order| order[:order_id].to_i.eql?(@order_id)}.nil?
    end

    def trades
      raise "Only available for own orders" if order_id.nil?
      @trades ||= {}
      response = CryptsyClient.connection.call(:mytrades, market_id)
      if response.success?
        response.each do |trade|
          if trade[:order_id] == order_id && @trades[trade[:trade_id]].nil?
            @trades[trade[:trade_id]] = Trade.new(market_id, trade)
          end
        end
      end
      @trades
    end

    def cancel
      CryptsyClient.connection.call(:cancelorder, order_id).success?
    end

    def execute!
      order = CryptsyClient.connection.call(:createorder, market_id, order_type, quantity, price)
      if order.success?
        @order_id = order[:order_id]
      else
        @error = order.error
        nil
      end
    end

  end

  class BuyOrder < Order
    def order_type
      "Buy"
    end
  end

  class SellOrder < Order
    def order_type
      "Sell"
    end
  end
end

