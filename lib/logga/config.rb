# frozen_string_literal: true

module Logga
  class Config
    attr_accessor :enabled, :excluded_fields, :excluded_suffixes

    def initialize(enabled: true, excluded_fields: [], excluded_suffixes: [])
      @enabled = enabled
      @excluded_fields = excluded_fields
      @excluded_suffixes = excluded_suffixes
    end
  end
end
