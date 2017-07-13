require 'active_support'
require 'active_support/core_ext'
require 'active_support/concern'
require_relative "logga/version"
require_relative "logga/active_record"


module Logga

  ActiveSupport.on_load(:active_record) do
    include Logga::ActiveRecord
  end

end
