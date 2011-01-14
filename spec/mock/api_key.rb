module Devise
  module Mock

    class ApiKey
      include Mongoid::Document
      devise :john_hancock_authenticatable, :authentication_keys => [:id]
    end

  end
end
