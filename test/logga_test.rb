# frozen_string_literal: true

require "test_helper"

class LoggaTest < Minitest::Test
  describe Logga do
    describe "VERSION" do
      let(:current_version) { File.read("VERSION").split("\n").first }

      it "should be set from the VERSION file" do
        assert_equal current_version, ::Logga::VERSION
      end
    end
  end
end
