module Devise
  module Mock

    class ApiKey
      include Mongoid::Document
      field :secret
      devise :john_hancock_authenticatable
    end

  end
end
