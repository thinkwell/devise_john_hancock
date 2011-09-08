module Devise

  # Tell if authentication through JohnHancock signatures is enabled.  False by default.
  mattr_accessor :signature_authenticatable
  @@signature_authenticatable = false

  # The JohnHancock::Signature algorithm used to authenticate the request
  # E.g. :simple
  mattr_accessor :signature_algorithm
  @@signature_algorithm = nil

  # Options to be passed to the signature algorithm
  mattr_accessor :signature_algorithm_options
  @@signature_algorithm_options = {}

  # Should we validate the signature?  Defaults to true.  Sometimes it is
  # helpful to set this to false when testing via a browser.
  mattr_accessor :signature_validate_signature
  @@signature_validate_signature = true

  # Should signature timestamps be validated if the JohnHancock signature
  # supports it them?
  mattr_accessor :signature_validate_timestamp
  @@signature_validate_timestamp = true

  # Defines the offset range (in seconds) for allowed timestamps (or nil to
  # use the default valid_timestamp_range of the JohnHancock signature)
  # E.g. To allow timestamps between 5 minutes in the past and 2 minutes in
  # the future: (-300..120)
  mattr_accessor :signature_timestamp_offset
  @@signature_timestamp_offset = nil

  mattr_accessor :john_hancock_logger
  @@john_hancock_logger = true
end
