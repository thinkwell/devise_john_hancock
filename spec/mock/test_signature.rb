module JohnHancock::Signature
  class DeviseTestSignature < JohnHancock::Signature::Base

    attr_accessor :secret

    def signature_base_string
      options[:signature_base_string] || 'foobar'
    end

    def signature
      options[:signature] || signature_base_string
    end

  end
end
