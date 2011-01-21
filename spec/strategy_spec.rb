require 'spec_helper'

module Devise::Strategies

  describe JohnHancockAuthenticatable do

    before(:each) do
      Devise.add_mapping(:mock_api_keys, :class_name => Devise::Mock::ApiKey)
      @model = Devise::Mock::ApiKey.new(:id => 555)
      stub(Devise::Mock::ApiKey).find_for_authentication({:id => '555'}){@model}
    end

    def strategy(uri)
      JohnHancockAuthenticatable.new(Rack::MockRequest.env_for(uri), :mock_api_key)
    end

    context "with a correct signature" do
      before(:each) do
        @strategy = strategy("http://example.com/categories/search?id=555&signature=foobar&timestamp=#{Time.now.to_i}")
      end

      it "is valid for checking authentication" do
        @strategy.should be_valid
      end

      it "authenticates" do
        @strategy.valid? && @strategy.authenticate!
        @strategy.should be_halted
        @strategy.result.should == :success
      end
    end


    context "with an incorrectly signed signature" do
      before(:each) do
        @strategy = strategy("http://example.com/categories/search?id=555&signature=fooBar&timestamp=#{Time.now.to_i}")
      end

      it "is valid for checking authentication" do
        @strategy.should be_valid
      end

      it "does not authenticate" do
        @strategy.valid? && @strategy.authenticate!
        @strategy.should be_halted
        @strategy.result.should == :failure
        @strategy.message.should == :invalid
      end
    end


    context "with an expired signature" do
      before(:each) do
        @strategy = strategy("http://example.com/categories/search?id=555&signature=foobar&timestamp=#{Time.now.to_i - 86400}")
      end

      it "is valid for checking authentication" do
        @strategy.should be_valid
      end

      it "does not authenticate" do
        @strategy.valid? && @strategy.authenticate!
        @strategy.should be_halted
        @strategy.result.should == :failure
        @strategy.message.should == :expired
      end
    end


    context "with no signature" do
      before(:each) do
        @strategy = strategy("http://example.com/categories/search?signature=foobar&timestamp=#{Time.now.to_i - 86400}")
      end

      it "is not valid for checking authentication" do
        @strategy.should_not be_valid
      end
    end

    context "with a non-existant api key" do
      before(:each) do
        stub(Devise::Mock::ApiKey).find_for_authentication({:id => '556'}){nil}
        @strategy = strategy("http://example.com/categories/search?id=556&signature=foobar&timestamp=#{Time.now.to_i}")
      end

      it "is valid for checking authentication" do
        @strategy.should be_valid
      end

      it "does not authenticate" do
        @strategy.valid? && @strategy.authenticate!
        @strategy.should_not be_halted
        @strategy.result.should == :failure
        @strategy.message.should == :invalid
      end
    end

  end
end
