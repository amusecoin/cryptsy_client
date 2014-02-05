module CryptsyClient
	class Configuration
		attr_accessor :public_key, :private_key

		def initialize
		end

		def configure
			yield self
		end
	end
end
