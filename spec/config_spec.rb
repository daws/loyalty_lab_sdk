require 'spec_helper'

describe LoyaltyLabSDK do

  context 'the static LoyaltyLabSDK module' do

    context 'config' do

      it 'should default to a hash' do
        subject.config.should be_instance_of(Hash)
      end

      it 'should allow keys to be set and retrieved' do
        subject.config(:value => 'komodo')
        subject.config[:value].should == 'komodo'
      end

    end

  end

end
