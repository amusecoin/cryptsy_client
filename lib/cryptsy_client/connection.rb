require 'timeout'
module CryptsyClient
  class ListResponse < Array
    def initialize(response)
      super response
      collect! do |item|
        if item.kind_of?(Hash)
          Response.new.parse_hash(item)
        elsif item.kind_of?(Array)
          Response.new.parse_array(item)
        elsif item.kind_of?(String) && item.match(/^\d+(?:\.\d+)?$/)
          item.to_f
        else
          item
        end
      end
    end

    def success?
      true
    end

  end

  class Response < Hash

    def initialize(response={})
      if response["success"].nil? || response["success"].to_i.eql?(1)
        self[:success] = true
      else
        self[:success] = false
        self[:error]   = response["error"]
      end
      merge!(parse_hash(response["return"].nil? ? response : response["return"]))
    end


    def success?
      self[:success]
    end

    def error
      self[:error]
    end

    def parse_hash(hash)
      out_hash = {}
      hash.each do |key, value|
        if value.kind_of?(String)
          if key.match(/id$/) && value.match(/^\d+$/)
            out_hash[key.gsub(/id$/, '_id').gsub(/__/, '_').gsub(/^_id$/, 'id').to_sym] = value.to_i
          elsif value.match(/^\d+(?:\.\d+)?$/) && key !~ /_code/
            out_hash[key.match(/[0-9A-Z]/) ? key : key.to_sym] = value.to_f
          else
            out_hash[key.to_sym] = value
          end
        elsif value.kind_of?(Hash)
          out_hash[key.match(/[0-9A-Z]/) ? key : key.to_sym] = parse_hash(value)
        elsif value.kind_of?(Array)
          out_hash[key.to_sym] = parse_array(value)
        else
          out_hash[key.to_sym] = value
        end
      end
      out_hash
    end

    def parse_array(array)
      out_array = []
      array.each do |item|
        if item.kind_of?(Hash)
          out_array << parse_hash(item)
        elsif item.kind_of?(Array)
          out_array << parse_array(item)
        else
          out_array << item
        end
      end
      out_array
    end

  end

  class Connection
    def initialize(api_public_key, api_private_key)
      @api_public_key = api_public_key
      @api_private_key = api_private_key
    end

    def api
      @api ||= Cryptsy::API::Client.new(@api_public_key, @api_private_key)
    end

    def call(method, *params)
      retrycount ||= 0
      Timeout.timeout(60) do
        response = api.send(method, *params)
        if response.kind_of?(Array)
          ListResponse.new(response)
        elsif response.kind_of?(Hash) && response["return"].kind_of?(Array)
          ListResponse.new(response["return"])
        else
          Response.new(response)
        end
      end
    rescue
      retrycount += 1
      retry unless retrycount > 2
      raise $!
    end
  end
end
