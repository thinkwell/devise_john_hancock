require 'spec_helper'
require 'john-hancock/request_proxy/uri'

module Devise::Models
  describe JohnHancockAuthenticatable do


    before(:each) do
      @model_class = Devise::Mock::ApiKey
      @model = @model_class.new
    end

    def signature(uri)
      request = Rack::Request.new(Rack::MockRequest.env_for(uri))
      proxy = JohnHancock::RequestProxy.proxy(request)
      JohnHancock::Signature::DeviseTestSignature.new(proxy)
    end


    it "adds config methods to model class" do
      @model_class.should respond_to('signature_authenticatable')
      @model_class.should respond_to('signature_algorithm')
      @model_class.should respond_to('signature_algorithm_options')
      @model_class.should respond_to('signature_validate_signature')
      @model_class.should respond_to('signature_validate_timestamp')
      @model_class.should respond_to('signature_timestamp_offset')
    end


    it "adds class methods to model class" do
      @model_class.should respond_to('signature_authenticatable?')
      @model_class.should respond_to('find_for_signature_authentication')
    end

    it "adds instance methods to model" do
      @model.should respond_to('valid_signature?')
      @model.should respond_to('configure_signature!')
      @model.should respond_to('after_signature_authentication')
    end


    describe 'signature_authenticatable?' do
      it "returns true when strategy is in an array of strategies" do
        stub(Devise).signature_authenticatable{[:john_hancock, :foo_bar]}
        @model_class.should be_signature_authenticatable(:john_hancock)
      end

      it "returns true for a globally true configuration" do
        stub(Devise).signature_authenticatable{true}
        @model_class.should be_signature_authenticatable(:john_hancock)
      end

      it "returns true for a globally false configuration" do
        stub(Devise).signature_authenticatable{false}
        @model_class.should_not be_signature_authenticatable(:john_hancock)
      end
    end


    describe 'signature' do
      before(:each) do
        @request = Rack::Request.new(Rack::MockRequest.env_for('http://example.com/'))
      end

      it "creates a new signature" do
        @model_class.signature(@request).should be_a(JohnHancock::Signature::Base)
      end

      it "uses the configured signature algorithm" do
        stub(Devise).signature_algorithm{:devise_test_signature}
        mock(JohnHancock::Signature).build.with_any_args do |*args|
          args[0].should == :devise_test_signature
        end
        @model_class.signature(@request)
      end

      it "overrides configured signature options with passed options" do
        stub(Devise).signature_algorithm_options{{:foo => 'bar'}}
        mock(JohnHancock::Signature).build.with_any_args do |*args|
          args[2].should == {:bar => 'foo'}
        end
        @model_class.signature(@request, {:bar => 'foo'})
      end

      it "uses the configured signature options if none are passed" do
        stub(Devise).signature_algorithm_options{{:foo => 'bar'}}
        mock(JohnHancock::Signature).build.with_any_args do |*args|
          args[2].should == {:foo => 'bar'}
        end
        @model_class.signature(@request)
      end
    end


    describe 'configure_signature!' do
      it "sets the secret" do
        s = signature("http://example.com/foo/bar")
        @model.secret = 'My new secret'
        @model.configure_signature!(s)
        s.secret.should == 'My new secret'
      end

      it "sets the valid timestamp range" do
        now = Time.now.to_i
        stub(Devise::Mock::ApiKey).signature_timestamp_offset{(-3..3)}
        s = signature("http://example.com/foo/bar")
        @model.configure_signature!(s, now)
        s.valid_timestamp_range.should == ((now-3)..(now+3))
      end
    end


    describe 'valid_signature?' do
      it "returns true for a valid signature" do
        t = Time.now.to_i
        s = signature("http://example.com/categories/search?foo=bar&test=123&signature=foobar&timestamp=#{t}")
        @model.configure_signature!(s)
        @model.valid_signature?(s).should == true
      end

      it "returns :invalid for invalid signature" do
        t = Time.now.to_i
        s = signature("http://example.com/categories/search?foo=bar&test=123&signature=fooBar&timestamp=#{t}")
        @model.configure_signature!(s)
        @model.valid_signature?(s).should == :invalid
      end

      it "returns :expired for invalid timestamp" do
        t = Time.now.to_i - 86400
        s = signature("http://example.com/categories/search?foo=bar&test=123&signature=foobar&timestamp=#{t}")
        @model.configure_signature!(s)
        @model.valid_signature?(s).should == :expired
      end

      it "does not validate signature if signature_validate_signature=false" do
        stub(Devise::Mock::ApiKey).signature_validate_signature{false}
        t = Time.now.to_i
        s = signature("http://example.com/categories/search?foo=bar&test=123&signature=raboof&timestamp=#{t}")
        @model.configure_signature!(s)
        @model.valid_signature?(s).should == true
      end

      it "does not validate timestamp if signature_validate_timestamp=false" do
        stub(Devise::Mock::ApiKey).signature_validate_timestamp{false}
        t = Time.now.to_i - 86400
        s = signature("http://example.com/categories/search?foo=bar&test=123&signature=foobar&timestamp=#{t}")
        @model.configure_signature!(s)
        @model.valid_signature?(s).should == true
      end
    end


    describe "signature_timestamp_offset" do
      it "accepts an integer offset" do
        stub(Devise::Mock::ApiKey).signature_timestamp_offset{86500}
        t = Time.now.to_i - 86400
        s = signature("http://example.com/categories/search?foo=bar&test=123&signature=foobar&timestamp=#{t}")
        @model.configure_signature!(s)
        @model.valid_signature?(s).should == true
      end

      it "accepts a range offset" do
        stub(Devise::Mock::ApiKey).signature_timestamp_offset{(-3..3)}
        t = Time.now.to_i + 5
        s = signature("http://example.com/categories/search?foo=bar&test=123&signature=foobar&timestamp=#{t}")
        @model.configure_signature!(s)
        @model.valid_signature?(s).should == :expired
      end
    end

  end
end
