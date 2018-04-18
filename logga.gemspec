# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "logga/version"

Gem::Specification.new do |spec|
  spec.name          = "logga"
  spec.version       = Logga::VERSION
  spec.authors       = ["Stuart Chinery, Rob Hesketh, Lorenzo Tello"]
  spec.email         = ["stuart.chinery@gmail.com, contact@robhesketh.com, ltello8a@gmail.com"]

  spec.summary       = "Extensions to ActiveRecord to log entries on model changes"
  spec.description   = "Extensions to ActiveRecord to log entries on model changes"
  spec.homepage      = "https://github.com/ltello/logga"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",      "~> 1.15"
  spec.add_development_dependency "rake",         "~> 10.0"
  spec.add_development_dependency "rspec",        "~> 3.6"
  spec.add_development_dependency "factory_girl", "~> 4.8"
  spec.add_development_dependency "byebug",       "~> 5.0"
  spec.add_development_dependency "simplecov"

  spec.add_runtime_dependency "activerecord",     "~> 5.2"
  spec.add_runtime_dependency "activesupport",    "~> 5.2"
end
