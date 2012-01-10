module LoyaltyLabSDK

  # An abstract super-class of all other LoyaltyLabApi Error classes
  class Error < StandardError; end
  
  # Indicates an error establishing a connection to the API, or a timeout that occurs while
  # making an API call. Is relatively common and transient- worth retrying in important cases.
  class ConnectionError < Error; end
  
  # Indicates an error authenticating with the provided credentials.
  class AuthenticationError < Error; end
  
  # Indicates any other API error (generally should be non-transient and not worth retrying). The
  # error code and string will be present in this error's message if one was provided in the
  # response.
  class UnknownError < Error; end

end
