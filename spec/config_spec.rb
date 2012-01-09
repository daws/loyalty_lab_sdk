require 'spec_helper'

describe LoyaltyLabSDK do

  context 'the static LoyaltyLabSDK module' do

    context 'config' do

      it 'should default to an empty hash' do
        subject.config.should be_instance_of(Hash)
        subject.config.should be_empty
      end

      it 'should allow keys to be set and retrieved' do
        subject.config(:username => 'komodo')
        subject.config[:username].should == 'komodo'
      end

    end

  end

end
