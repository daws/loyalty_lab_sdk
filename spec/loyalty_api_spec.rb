require 'spec_helper'

describe LoyaltyLabSDK::LoyaltyAPI do

  context 'an instance initialized with defaults' do

    it 'should respond successfully to GetEventDefinitions' do
      lambda { subject.GetEventDefinitions }.should_not raise_error
    end

    it 'should allow junk shopper to be created' do
      shopper = subject.build_default_shopper(Guid.new.to_s)
      shopper['EmailAddress'] = "#{Guid.new.to_s}@stashrewards.com"
      shopper['FirstName'] = Guid.new.to_s
      shopper['LastName'] = Guid.new.to_s
      lambda { subject.CreateShopper('shopper' => shopper) }.should_not raise_error
    end

  end

  context 'a lazy-authenticated instance initialized with defaults' do
    
    subject do
      LoyaltyLabSDK::LoyaltyAPI.new(:lazy_authentication => true)
    end

    it 'should authenticate automatically' do
      lambda { subject.GetEventDefinitions }.should_not raise_error
    end

  end

  context 'a lazy-authenticated instance with bogus credentials' do

    subject do
      LoyaltyLabSDK::LoyaltyAPI.new(:username => 'bogus', :password => 'junk', :lazy_authentication => true)
    end

    it 'should raise an authentication error when authenticating' do
      lambda { subject.authenticate! }.should raise_error(LoyaltyLabSDK::AuthenticationError)
    end

  end

  context 'a lazy-authenticated instance with an open_timeout of 0.000001 seconds' do

    subject do
      LoyaltyLabSDK::LoyaltyAPI.new(:open_timeout => 0.000001, :lazy_authentication => true)
    end

    it 'should timeout when authenticating' do
      lambda { subject.authenticate! }.should raise_error(LoyaltyLabSDK::ConnectionError)
    end

  end

  context 'a lazy-authenticated instance with an read_timeout of 0.000001 seconds' do

    subject do
      LoyaltyLabSDK::LoyaltyAPI.new(:read_timeout => 0.000001, :lazy_authentication => true)
    end

    it 'should timeout when authenticating' do
      lambda { subject.authenticate! }.should raise_error(LoyaltyLabSDK::ConnectionError)
    end

    it 'should attempt to authenticate 3 times' do
      subject.instance_eval do
        @retry_attempts = 0
        def retry_attempts; @retry_attempts; end

        def call_api_method(method_name, request_body = nil, options = {})
          @retry_attempts += 1
          super(method_name, request_body, options)
        end
      end
      lambda { subject.authenticate! }.should raise_error(LoyaltyLabSDK::ConnectionError)
      subject.retry_attempts.should == 3
    end

  end

end
