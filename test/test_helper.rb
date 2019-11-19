# frozen_string_literal: true

require "simplecov"

SimpleCov.start do
  minimum_coverage 40 # Yep it is poor!
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "logga"

require "minitest/autorun"
require "minitest/bang"
require "minitest/fail_fast"
require "minitest/macos_notification"
require "minitest/reporters"

Minitest::Reporters.use!(
  [
    Minitest::Reporters::SpecReporter.new,
    Minitest::Reporters::MacosNotificationReporter.new(title: "Logga gem")
  ],
  "test",
  Minitest.backtrace_filter
)

module Minitest
  class Test
    extend Minitest::Spec::DSL
  end
end
