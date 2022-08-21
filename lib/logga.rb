# frozen_string_literal: true

require "active_support"
require "active_support/core_ext"
require "active_support/concern"

require_relative "logga/active_record"
require_relative "logga/config"
require_relative "logga/version"

module Logga
  ActiveSupport.on_load(:active_record) do
    include Logga::ActiveRecord
  end

  class << self
    def configuration
      @configuration ||= Config.new
    end

    def configure
      yield(configuration)
    end

    # Switches Logga on or off
    def enabled=(value)
      configuration.enabled = value
    end

    # Returns `true` if Logga is on, `false` otherwise
    def enabled?
      !!configuration.enabled
    end

    def version
      Logga::VERSION
    end
  end
end
