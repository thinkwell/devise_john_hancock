require 'devise_john_hancock/strategy'

module Devise::Models
  module JohnHancockAuthenticatable
    extend ActiveSupport::Concern

    def valid_signature?(signature)
      configure_signature!(signature)
      return :invalid unless !validate_signature? || signature.valid_signature?
      return :expired unless !validate_timestamp? || signature.valid_timestamp?
      true
    end

    # Subclasses should override configure_signature! to work with
    # the choosen signature algorithm
    # The default works with the :simple algorithm
    def configure_signature!(signature, base_time=nil)
      add_timestamp_to_signature(signature, base_time)
      add_secret_to_signature(signature)
    end

    def after_signature_authentication
    end


  private

    def validate_signature?
      !!self.class.signature_validate_signature
    end

    def validate_timestamp?
      !!self.class.signature_validate_timestamp
    end

    def add_timestamp_to_signature(signature, base_time=nil)
      base_time ||= Time.now
      if(offset = self.class.signature_timestamp_offset)
        offset = (-offset..offset) unless offset.is_a?(Range)
        signature.valid_timestamp_range = ((offset.min.to_i + base_time.to_i)..(offset.max.to_i + base_time.to_i)) if signature.respond_to?(:valid_timestamp_range=)
      end
    end

    def add_secret_to_signature(signature)
      signature.secret = secret if signature.respond_to?(:secret=)
    end

    module ClassMethods
      Devise::Models.config(self, :signature_authenticatable, :signature_algorithm, :signature_algorithm_options, :signature_validate_signature, :signature_validate_timestamp, :signature_timestamp_offset)

      def signature_authenticatable?(strategy)
        signature_authenticatable.is_a?(Array) ?
          signature_authenticatable.include?(strategy) : signature_authenticatable
      end

      def signature(request, options=nil)
        options = signature_algorithm_options || {} unless options
        JohnHancock::Signature.build(signature_algorithm, request, options)
      end

      # We assume this method already gets the sanitized values from the
      # JohnHancockAuthenticatable strategy. If you are using this method on
      # your own, be sure to sanitize the conditions hash to only include
      # the proper fields.
      def find_for_signature_authentication(conditions)
        find_for_authentication(conditions)
      end
    end
  end
end
