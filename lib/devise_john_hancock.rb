require 'devise'
require 'john-hancock'
require 'john-hancock/request_proxy/rack_request'

require 'devise_john_hancock/logger'
require 'devise_john_hancock/config'
require 'devise_john_hancock/schema'
require 'devise_john_hancock/strategy'

Devise.add_module( :john_hancock_authenticatable,
  :strategy => true,
  :model => 'devise_john_hancock/model'
)
