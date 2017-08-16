module Logga
  module ActiveRecord
    extend ActiveSupport::Concern

    EXCLUDED_KEYS          = [:created_at, :deleted_at, :initial, :updated_at, :log, :sent_photos_chaser_email, :sent_after_sales_emails]
    EXCLUDED_KEYS_SUFFIXES = [:_id, :_filenames]

    included do
      class_attribute :log_fields, instance_writer: false
      self.log_fields = {}
    end

    class_methods do
      def add_log_entries_for(*actions, to: :self, fields: {})
        after_create  :log_model_creation if actions.include?(:create)
        after_destroy :log_model_deletion if actions.include?(:delete)
        after_update  :log_model_changes  if actions.include?(:update)
        define_method(:log_receiver) { to == :self ? self : send(to) }
        self.log_fields = fields
      end
    end

    def log_model_creation
      body_generator = ->(record) { default_creation_log_body(record) }
      body = log_fields.fetch(:created_at, body_generator).call(self)
      log_receiver&.log_entries&.create(author_data.merge(body: body))
    end

    def log_model_deletion
      body_generator = ->(record) {default_deletion_log_body(record)}
      body           = log_fields.fetch(:deleted_at, body_generator).call(self)
      log_receiver&.log_entries&.create(author_data.merge(body: body))
    end

    def log_model_changes
      field_changes = changes.reject do |k, _|
        EXCLUDED_KEYS.include?(k.to_sym) ||
        EXCLUDED_KEYS_SUFFIXES.any? { |suffix| k.to_s.end_with?(suffix.to_s) }
      end
      log_field_changes(field_changes)
    end

    def log_field_changes(changes)
      if changes.present?
        body_generator = ->(record, field, old_value, new_value) { default_change_log_body(record, field, old_value, new_value) }
        body = changes.inject([]) do |result, (field, (old_value, new_value))|
          result << log_fields.fetch(field.to_sym, body_generator).call(self, field, old_value, new_value)
        end.join('\n')
        log_receiver&.log_entries&.create(author_data.merge(body: body))
      end
    end

    private

    def author_data
      data = Hash(log_receiver.try(:author) || try(:author)).with_indifferent_access
      {
          author_id:   data[:id],
          author_type: data[:type],
          author_name: data[:name]
      }
    end

    def default_creation_log_body(record)
      [
        "#{titleized_model_class_name(record)} created",
        ("(#{record.state})" if record.try(:state))
      ].compact.join(' ')
    end

    def default_change_log_body(record, field, old_value, new_value)
      "#{titleized_model_class_name(record)} #{field.humanize(capitalize: false)} set to #{new_value}"
    end

    def default_deletion_log_body(record)
      [
        "#{titleized_model_class_name(record)} removed",
        ("(#{record.name})" if record.try(:name))
      ].compact.join(' ')
    end

    def titleized_model_class_name(record)
      record.class.name.demodulize.titleize
    end
  end
end
