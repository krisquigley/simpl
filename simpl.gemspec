# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "simpl/version"

Gem::Specification.new do |s|
  s.name        = "simpl"
  s.version     = Simpl::VERSION
  s.authors     = ["Ryan Townsend"]
  s.email       = ["ryan@ryantownsend.co.uk"]
  s.homepage    = ""
  s.summary     = %q{Shortens URLs using the Goo.gl service}
  s.description = s.summary

  s.rubyforge_project = "simpl"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "httparty"
  s.add_development_dependency "webmock", "~> 1.8"
  s.add_development_dependency "rake", "~> 0.9"
  s.add_development_dependency "rspec", "~> 2.8"
  s.add_development_dependency "vcr", "~> 2.1"
  s.add_development_dependency "simplecov", "~> 0.6"
  s.add_development_dependency "json", "~> 1.6"
end
