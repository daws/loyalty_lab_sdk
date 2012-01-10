require 'httpi'
require 'net/http'

# prevents debug log messages that clutter output
HTTPI.log = false

# prevents warning
class Net::HTTP
  alias_method :old_initialize, :initialize
  def initialize(*args)
    old_initialize(*args)
    @ssl_context = OpenSSL::SSL::SSLContext.new
    @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end

require 'loyalty_lab_sdk/config'
require 'loyalty_lab_sdk/exceptions'

module LoyaltyLabSDK

  autoload :LoyaltyAPI, 'loyalty_lab_sdk/loyalty_api'

end
