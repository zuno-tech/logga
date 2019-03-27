# frozen_string_literal: true

# rubocop:disable Style/ExpandPathArguments
# NOTE: This is because of Gemfury failing with __dir__
lib = File.expand_path("../lib", __FILE__)
# rubocop:enable Style/ExpandPathArguments
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "logga/version"

Gem::Specification.new do |spec|
  spec.name          = "logga"
  spec.version       = Logga::VERSION
  spec.authors       = ["Boxt"]
  spec.email         = ["developers@boxt.co.uk"]

  spec.summary       = "ActiveRecord log entries on model changes"
  spec.description   = "Extensions to ActiveRecord to log entries on model changes"
  spec.homepage      = "https://github.com/boxt/logga"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "boxt_ruby_style_guide", "~> 2.1"
  spec.add_development_dependency "bundler",               "~> 1.17"
  spec.add_development_dependency "byebug",                "~> 10.0"
  spec.add_development_dependency "rake",                  "~> 12.3"
  spec.add_development_dependency "rspec",                 "~> 3.6"
  spec.add_development_dependency "simplecov",             "~> 0.16"

  spec.add_runtime_dependency "activerecord",  "~> 5.2"
  spec.add_runtime_dependency "activesupport", "~> 5.2"
end
