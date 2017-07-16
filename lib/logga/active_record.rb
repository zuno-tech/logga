module Logga
  module ActiveRecord
    extend ActiveSupport::Concern

    class_methods do
      def add_log_entries_for(*actions, to: :self)
        after_create :log_model_creation if actions.include?(:create)
        after_update :log_model_changes  if actions.include?(:update)
        define_method(:log_receiver) { to == :self ? self : send(to) }
      end
    end

    def log_model_creation
      body = "#{self.class} created"
      log_receiver.log_entries.create(author_data.merge(body: body))
    end

    def log_model_changes
      field_changes = changes.except(:created_at, :updated_at, :log)
      log_field_changes(field_changes)
    end

    def log_field_changes(changes)
      changes.each { |field, values| log_field_change(field, *values) }
    end

    def log_field_change(field, old_value, new_value)
      body = "changed #{field} from #{old_value} to #{new_value}"
      log_receiver.log_entries.create(author_data.merge(body: body))
    end

    def author_data
      data = Hash(log_receiver.author).with_indifferent_access
      {
          author_id:   data[:id],
          author_type: data[:type],
          author_name: data[:name]
      }
    end
  end
end