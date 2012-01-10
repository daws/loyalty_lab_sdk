require 'date'
require 'loyalty_lab_sdk/exceptions'
require 'active_support/inflector'
require 'savon'

module LoyaltyLabSDK
class LoyaltyAPI

  ENDPOINT = 'https://api.loyaltylab.com/loyaltyapi/loyaltyapi.asmx'
  NAMESPACE = 'http://www.loyaltylab.com/loyaltyapi/'

  # Constructs an object-oriented API to loyalty lab.
  #
  # In addition to the options specified below, any of the options documented
  # in LoyaltyLabSDK#config may be overridden.
  #
  # It will establish a connection, authenticate the username/password, and store
  # the authentication data upon construction unless the lazy_authentication
  # parameter is set. This authentication token times out after 20 minutes
  # (double-check Loyalty Lab's documentation), so a client wishing to use this
  # object should accommodate that, and re-call #authenticate! if necessary.
  #
  # @param [Hash] options
  # @option options [boolean] :lazy_authentication (false) Delays authentication
  #   until either the first call is made or it is done explicitly.
  def initialize(options = {})
    self.config = {
      :lazy_authentication => false
    }.merge!(LoyaltyLabSDK.config).merge!(options)

    Savon.configure do |c|
      c.logger = config[:logger]
      c.raise_errors = false
    end

    initialize_client

    @authenticated = false

    unless config[:lazy_authentication]
      authenticate!
    end
  end

  # Authenticates the client.
  #
  # This method is called by the constructor unless lazy_authentication is
  # on, so this will not typically need to be invoked directly.
  #
  # An object that hasn't been called in 20 minutes will have its
  # authentication headers expired by Loyalty Lab, requiring this method to
  # be invoked again on long-lived objects.
  def authenticate!
    response = self.AuthenticateUser(
      { :username => config[:username], :password => config[:password] },
      :is_authenticate => true)

    auth_data = {
      :retailer_guid => response['RetailerGuid'],
      :authenticated => response['Authenticated'],
      :token => response['Token'],
      :ics_user_id => response['ICSUserID']
    }

    if !auth_data[:authenticated]
      raise AuthenticationError, 'authentication failed'
    end

    self.retailer_guid = auth_data[:retailer_guid]

    self.auth_header = {
      "wsdl:AuthenticationResult" => {
        "wsdl:RetailerGuid" => auth_data[:retailer_guid],
        "wsdl:Authenticated" => auth_data[:authenticated],
        "wsdl:Token" => auth_data[:token],
        "wsdl:ICSUserID" => auth_data[:ics_user_id],
      }
    }

    @authenticated = true
  end

  # Implements most API calls. The API method should be passed as defined in Loyalty
  # Lab's API documentation here: http://api.loyaltylab.com/loyaltyapi/help/index.html
  #
  # Each of the parameters should be passed in a hash as documented.
  #
  # Responses will be in the documented format (a "string" return value with respond
  # with a string, etc...), or if it's an object (such as a Shopper object), the
  # result will be a hash with string keys for object
  #
  # == Examples:
  #
  # === Retrieve a shopper
  #  shopper = api.GetShopperByEmail 'email' => 'test@gmail.com'
  #
  # === Adjust shopper point balance
  #  point_balance = api.AdjustShopperPoints 'shopperId' => shopper['ShopperId'],
  #   'pointChange' => 1000,
  #   'pointType' => 'Base',
  #   'description' => 'Bonus'
  #
  # === Create a shopper with card
  #  new_shopper = api.build_default_shopper(1234)
  #  new_shopper['EmailAddress'] = 'test2@gmail.com'
  #  new_shopper['FirstName'] = 'Joe'
  #  new_shopper['LastName'] = 'Schmoe'
  #  new_card = api.build_default_card(1234)
  #  api.CreateShopperWithCard 'shopper' => new_shopper, 'card' => new_card
  def method_missing(method_name, *args)
    call_api_method(method_name, *args)
  end

  # Initializes and returns a shopper object with default fields set for use with a
  # CreateShopper call.
  #
  # This object should be updated with all relevant fields (ie. email address, first
  # name, phone number, etc) before being saved.
  def build_default_shopper(retailer_shopper_id)
    now = DateTime.now

    {
      'ShopperId' => 0,
      'RetailerGUID' => retailer_guid,
      'EmailAddress' => '',
      'EmailFrequency' => 1,
      'EmailFrequencyUnit' => 'D',
      'EmailFormat' => 'HTML',
      'Password' => ' ',
      'Status' => 'A',
      'LastName' => '',
      'MiddleInitial' => '',
      'FirstName' => '',
      'Address1' => '',
      'City' => '',
      'State' => '',
      'Zip' => '',
      'PhoneNumber' => '',
      'ProfileCreateDateTime' => now,
      'ProfileUpdateDateTime' => now,
      'CreateDateTime' => now,
      'PasswordLastChanged' => now,
      'Origin' => 'W',
      'RetailerShopperId' => retailer_shopper_id.to_s,
      'FileImportId' => 0,
      'BulkEmail' => 1,
      'LoyaltyMember' => true,
      'PersonStatus' => 'P',
      'RetailerRegistered' => false,
      'MailOptIn' => false,
      'PhoneOptIn' => false,
      'RetailerShopperCreationDate' => now,
      'LoyaltyLabCreateDateTime' => now,
      'StatusUpdateDateTime' => now
    }
  end

  # Initializes and returns a card object with default fields set for use with a
  # CreateShopper call.
  #
  # This object should be updated with all relevant fields before being saved (if
  # necessary).
  def build_default_card(retailer_shopper_id)
    now = DateTime.now

    {
      'RegisteredCardId' => 0,
      'ShopperId' => 0,
      'CommonName' => 'loyalty member id',
      'AlternateCardIdentifier' => retailer_shopper_id.to_s,
      'CardType' => 'L',
      'ExpirationMonth' => 12,
      'ExpirationYear' => 3010,
      'LastFour' => ' ',
      'CardHolderName' => ' ',
      'Status' => 'A',
      'CreateDateTime' => now,
      'IsPreferred' => ' ',
      'FileImportId' => 0
    }
  end

  private

  ERROR_HANDLERS = {
    '100' => AuthenticationError
  }

  SHOPPER_FIELD_MAPPINGS = {
    :retailer_guid => 'RetailerGUID'
  }

  FIELD_MAPPING = {
    'AuthenticateUser' => {
      :ics_user_id => 'ICSUserID'
    },
    'GetShopperByID' => SHOPPER_FIELD_MAPPINGS,
    'GetShopperByEmail' => SHOPPER_FIELD_MAPPINGS,
    'GetShopperByRetailerID' => SHOPPER_FIELD_MAPPINGS
  }

  attr_accessor :config, :client, :retailer_guid, :auth_header

  def initialize_client
    self.client = ::Savon::Client.new do
      wsdl.endpoint = ENDPOINT
      wsdl.namespace = NAMESPACE
      http.open_timeout = config[:open_timeout]
      http.read_timeout = config[:read_timeout]
    end
  end

  def call_api_method(method_name, request_body = nil, options = {})
    options = {
      :is_authenticate => false,
      :connection_error_retries => LoyaltyLabSDK.config[:connection_error_retries],
    }.merge(options)

    if !@authenticated && !options[:is_authenticate]
      authenticate!
    end

    method_name = method_name.to_s

    request_body ||= {}

    prepared_request_body = prepare_request(request_body)

    begin
      response = client.request "wsdl:#{method_name}" do |soap, wsdl, http, wsse|
        http.headers["SOAPAction"] = "http://www.loyaltylab.com/loyaltyapi/#{method_name}"
        soap.header = auth_header unless options[:is_authenticate]
        soap.body = prepared_request_body
      end
    rescue Exception => e
      config[:logger].debug "communication exception during request: #{e.message}"
      if options[:connection_error_retries] > 0
        config[:logger].debug "#{options[:connection_error_retries]} retry attempt(s) remaining; retrying..."
        options[:connection_error_retries] -= 1
        return call_api_method(method_name, request_body, options)
      else
        config[:logger].debug 'no retry attempts remaining'
        raise ConnectionError, e.message
      end
    end

    check_response_for_errors(response)

    modified_method_name = method_name.underscore

    response = response.to_hash["#{modified_method_name}_response".to_sym]
    response = response["#{modified_method_name}_result".to_sym] unless response.nil?

    normalize_response method_name, response
  end

  # Returns a request hash with proper namespacing prefixes and transformations applied
  # to the given request hash.
  def prepare_request(request_hash = {}, nested_object = false)
    result = {}
    request_hash.each do |key, value|
      # handle nested objects in the request (like a shopper)
      value = prepare_request(value, true) if value.instance_of?(Hash)

      # add the wsdl: prefix to the key
      result["wsdl:#{key}"] = value
    end
    result
  end

  # Takes a raw response and checks it for errors, throwing proper exceptions if
  # present.
  def check_response_for_errors(response)
    # take no action if there are no errors
    return unless response.soap_fault? || response.http_error?

    response_hash = response.to_hash
    if response_hash[:fault] && response_hash[:fault][:detail]
      # we can parse the response, so check the specific error code
      error_code = response_hash[:fault][:detail][:code]

      # if we can recognize the specific code, dispatch the proper exception
      if ERROR_HANDLERS.has_key? error_code
        raise ERROR_HANDLERS[error_code], response_hash[:fault][:faultstring]
      end

      # otherwise return a well-defined error string with the code and error message
      raise UnknownError, "#{response_hash[:fault][:detail][:code]} #{response_hash[:fault][:detail][:description]}: #{response_hash[:fault][:faultstring]}"
    end

    # we can't parse the error, so just pass back the entire response body
    raise UnknownError, response.to_s
  end

  def normalize_response(method_name, response, mapping = FIELD_MAPPING[method_name])
    if response.instance_of?(Hash)
      mapping ||= {}
      response.inject({}) do |hash, (key, value)|
        new_key = mapping[key] || key.to_s.camelize
        hash[new_key] = normalize_response(nil, value, nil) # TODO: implement nested mappings
        hash
      end
    elsif response.instance_of?(Array)
      response.collect do |value|
        normalize_response(nil, value, nil) # TODO: implement nested mappings
      end
    else
      response
    end
  end

end
end
