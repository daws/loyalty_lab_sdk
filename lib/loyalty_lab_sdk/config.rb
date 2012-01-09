module LoyaltyLabSDK

  def self.config(options = nil)
    @config ||= {}
    @config.merge! options if options
    @config
  end

end
