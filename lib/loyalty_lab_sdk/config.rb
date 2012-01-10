require 'logger'

module LoyaltyLabSDK

  DEFAULT_TIMEOUT = 15
  DEFAULT_RETRIES = 2

  # Globally configures and retrieves configuration for the Loyalty Lab SDK.
  #
  # == Environment Variables
  #
  # For convenience in a command-line environment, configuration may be skipped
  # by setting the LOYALTY_LAB_SDK_USERNAME and LOYALTY_LAB_SDK_PASSWORD
  # environment variables, which are self-explanatory.
  #
  # == Rails
  #
  # If running in a rails environment, this configuration will automatically use
  # the global Rails.logger instance. This behavior may be overridden by passing
  # in a :logger option.
  #
  # @param [Hash] options
  # @option options [String] :username (nil) Loyalty Lab account username
  # @option options [String] :password (nil) Loyalty Lab account password
  # @option options [Logger] :logger (Rails.logger) Logger to use
  # @option options [Numeric] :open_timeout (LoyaltyLabSDK::DEFAULT_TIMEOUT)
  #   Number of seconds to wait for the connection to open
  #   (see Net::HTTP#open_timeout)
  # @option options [Numeric] :read_timeout (LoyaltyLabSDK::DEFAULT_TIMEOUT)
  #   Number of seconds to wait for one block to be read
  #   (see Net::HTTP#read_timeout)
  # @option options [Integer] :connection_error_retries
  #   (LoyaltyLabSDK::DEFAULT_RETRIES) Number of retries that will be attempted
  #   if a connection error (timeout) occurs
  def self.config(options = nil)
    @config ||= {
      :username => ENV['LOYALTY_LAB_SDK_USERNAME'],
      :password => ENV['LOYALTY_LAB_SDK_PASSWORD'],
      :logger => default_logger,
      :open_timeout => DEFAULT_TIMEOUT,
      :read_timeout => DEFAULT_TIMEOUT,
      :connection_error_retries => DEFAULT_RETRIES,
    }
    
    @config.merge!(options) if options

    @config
  end

  private

  def self.default_logger
    if defined?(::Rails)
      ::Rails.logger
    else
      logger = ::Logger.new(STDERR)
      logger.level = ::Logger::INFO
      logger
    end
  end

end
