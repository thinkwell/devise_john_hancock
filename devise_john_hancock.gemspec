# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "devise_john_hancock/version"

Gem::Specification.new do |s|
  s.name        = %q{devise_john_hancock}
  s.version     = DeviseJohnHancock::VERSION
  s.authors     = ["Brandon Turner"]
  s.email       = ["bt@brandonturner.net"]
  s.homepage    = %q{http://github.com/thinkwell/devise_john_hancock}
  s.summary     = %q{API query signature authentication support for Devise}
  s.description = %q{API query signature authentication support for Devise using query parameters or HTTP headers}

  s.rubyforge_project = "devise_john_hancock"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency(%q<rails>, [">= 3.0.0"])
  s.add_runtime_dependency(%q<devise>, [">= 2.0.0"])
  s.add_runtime_dependency(%q<john-hancock>, [">= 0.0.7", "< 0.1.0"])

  s.add_development_dependency(%q<bundler>, [">= 1.0.21"])
  s.add_development_dependency(%q<rake>, [">= 0"])
end
