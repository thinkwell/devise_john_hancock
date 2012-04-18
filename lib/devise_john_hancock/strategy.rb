require 'devise/strategies/base'

module Devise::Strategies
  class JohnHancockAuthenticatable < Base

    def valid?
      valid_for_signature_auth?
    end

    def authenticate!
      resource = mapping.to.find_for_signature_authentication(signature_auth_hash)

      if validate(resource){ resource.valid_signature?(signature) }
        return if halted?
        DeviseJohnHancockAuthenticatable::Logger.send("authenticated!")
        resource.after_signature_authentication
        success!(resource)
      else
        return if halted?
        DeviseJohnHancockAuthenticatable::Logger.send("not authenticated!")
        fail(:invalid)
      end
    end

    def store?
      # Don't store object in a cookie, this strategy is stateless
      false
    end


  private

    def valid_for_signature_auth?
      signature_authenticatable? && valid_signature_algorithm? && valid_signature_format?
    end

    def signature_authenticatable?
      mapping.to.signature_authenticatable?(:john_hancock)
    end

    def valid_signature_algorithm?
      JohnHancock::Signature.algorithm_exists?(mapping.to.signature_algorithm)
    end

    def valid_signature_format?
      signature.valid_format?
    end

    def signature_auth_hash
      @signature_auth_hash ||= signature.id_hash
    end

    def signature
      @signature ||= mapping.to.signature(request)
    end

    # Simply invokes valid_for_authentication? with the given block and deal with the result.
    def validate(resource, &block)
      result = resource && resource.valid_for_authentication?(&block)

      case result
      when String, Symbol
        fail!(result)
        false
      when TrueClass
        true
      else
        result
      end
    end

  end
end

Warden::Strategies.add(:john_hancock_authenticatable, Devise::Strategies::JohnHancockAuthenticatable)
