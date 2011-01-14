require 'devise/strategies/authenticatable'

module Devise::Strategies
  class JohnHancockAuthenticatable < Authenticatable

    def valid?
      valid_for_signature_auth?
    end

    def authenticate!
      resource = mapping.to.find_for_signature_authentication(authentication_hash)
      resource.configure_signature!(signature)

      if validate(resource){ resource.valid_signature?(signature) }
        return if halted?
        resource.after_signature_authentication
        success!(resource)
      else
        return if halted?
        fail(:invalid)
      end
    end

    def store?
      # Don't store object in a cookie, this strategy is stateless
      false
    end


  private

    def valid_for_signature_auth?
      signature_authenticatable? && valid_signature_algorithm? &&
      valid_signature_format? && with_authentication_hash(signature_auth_hash)
    end

    def signature_authenticatable?
      mapping.to.signature_authenticatable?(authenticatable_name)
    end

    def valid_signature_algorithm?
      JohnHancock::Signature.algorithm_exists?(mapping.to.signature_algorithm)
    end

    def valid_signature_format?
      signature_auth_hash.is_a?(Hash)
    end

    def signature_auth_hash
      @signature_auth_hash ||= signature.id_hash
    end

    def signature
      @signature ||= mapping.to.signature(request)
    end

  end
end

Warden::Strategies.add(:john_hancock_authenticatable, Devise::Strategies::JohnHancockAuthenticatable)
