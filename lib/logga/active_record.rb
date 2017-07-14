module Logga
  module ActiveRecord
    extend ActiveSupport::Concern

    class_methods do
      def add_log_entries_for(*actions)
        after_create :log_model_creation if actions.include?(:create)
        after_update :log_model_changes  if actions.include?(:update)
      end
    end

    def log_model_creation
      body = "#{self.class} created"
      self.log_entries.create(author_data.merge(body: body))
    end

    def log_model_changes
      field_changes = changes.except(:created_at, :updated_at, :log)
      log_field_changes(field_changes, author)
    end

    def log_field_changes(changes, author)
      changes.each { |field, values| log_field_change(field, *values, author) }
    end

    def log_field_change(field, old_value, new_value, author)
      body = "changed #{field} from #{old_value} to #{new_value}"
      self.log_entries.create(author_data.merge(body: body))
    end

    def author_data
      data = Hash(author).with_indifferent_access
      {
        author_id:   data[:id],
        author_type: data[:type],
        author_name: data[:name]
      }
    end
  end
end