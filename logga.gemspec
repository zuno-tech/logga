# frozen_string_literal: true

# NOTE: This is because of Gemfury failing with __dir__
lib = File.expand_path("lib", __dir__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "logga/version"

Gem::Specification.new do |spec|
  spec.required_ruby_version = ">= 2.7"
  spec.name = "logga"
  spec.version = Logga::VERSION
  spec.authors = ["Boxt"]
  spec.email = ["developers@boxt.co.uk"]
  spec.summary = "ActiveRecord log entries on model changes"
  spec.description = "Extensions to ActiveRecord to log entries on model changes"
  spec.homepage = "https://github.com/boxt/logga"
  spec.license = "MIT"
  spec.metadata = {
    "rubygems_mfa_required" => "true"
  }

  spec.files = Dir[
    "lib/**/*",
    "MIT-LICENSE",
    "Rakefile",
    "README.md",
    "VERSION"
  ]

  spec.add_runtime_dependency "activerecord", ">= 5.2", "~> 6.0"
  spec.add_runtime_dependency "activesupport", ">= 6", "< 8"
end
