# frozen_string_literal: true

# rubocop:disable Style/ExpandPathArguments
# NOTE: This is because of Gemfury failing with __dir__
lib = File.expand_path("../lib", __FILE__)
# rubocop:enable Style/ExpandPathArguments
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "logga/version"

Gem::Specification.new do |spec|
  spec.name = "logga"
  spec.version = Logga::VERSION
  spec.authors = ["Boxt"]
  spec.email = ["developers@boxt.co.uk"]
  spec.summary = "ActiveRecord log entries on model changes"
  spec.description = "Extensions to ActiveRecord to log entries on model changes"
  spec.homepage = "https://github.com/boxt/logga"
  spec.license = "MIT"

  spec.files = Dir[
    "lib/**/*",
    "MIT-LICENSE",
    "Rakefile",
    "README.md",
    "VERSION"
  ]

  spec.add_runtime_dependency "activerecord", ">= 5.2"
  spec.add_runtime_dependency "activesupport", ">= 5.2"
  spec.add_development_dependency "boxt_ruby_style_guide", "~> 4.2"
  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "byebug", "~> 11.0"
  spec.add_development_dependency "factory_bot", "~> 4.8"
  spec.add_development_dependency "minitest", "~> 5.13"
  spec.add_development_dependency "minitest-bang", "~> 1.0"
  spec.add_development_dependency "minitest-fail-fast", "~> 0.1"
  spec.add_development_dependency "minitest-macos-notification", "~> 0.3"
  spec.add_development_dependency "minitest-reporters", "~> 1.4"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "simplecov", "~> 0.17"
end
