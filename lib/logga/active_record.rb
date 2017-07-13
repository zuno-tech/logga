module Logga
  module ActiveRecord
    extend ActiveSupport::Concern

    class_methods do
      def add_log_entries_for(*actions)
        around_update :log_model_changes if actions.include?(:update)
      end
    end

    def log_model_changes
      field_changes = changes
      log_field_changes(field_changes) if yield
    end

    def log_field_changes(changes)
      changes.each { |field, values| log_field_change(field, *values) }
    end

    def log_field_change(field, old_value, new_value)
      author_data = Hash(try(:author))
      self.log_entries.create(
          body:      "changed #{field} from #{old_value} to #{new_value}",
          author_id:   author_data[:id],
          author_tupe: author_data[:type],
          author_name: author_data[:name]
      )
    end
  end
end