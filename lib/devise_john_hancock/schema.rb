Devise::Schema.class_eval do
  def john_hancock_authenticatable(options={})
    null    = options[:null] || false
    default = options.key?(:default) ? options[:default] : ("" if null == false)

    apply_devise_schema :secret, String, :null => null, :default => default
  end
end
