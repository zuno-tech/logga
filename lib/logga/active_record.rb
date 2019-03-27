# frozen_string_literal: true

module Logga
  module ActiveRecord
    extend ActiveSupport::Concern

    EXCLUDED_KEYS          = %i[id created_at deleted_at initial updated_at log sent_after_sales_emails].freeze
    EXCLUDED_KEYS_SUFFIXES = %i[_id _filenames].freeze

    included do
      class_attribute :log_fields,      instance_writer: false
      class_attribute :excluded_fields, instance_writer: false
      self.log_fields      = {}
      self.excluded_fields = {}
    end

    class_methods do
      def add_log_entries_for(*actions, to: :self, fields: {}, exclude_fields: [])
        after_create  :log_model_creation if actions.include?(:create)
        after_destroy :log_model_deletion if actions.include?(:delete)
        after_update  :log_model_changes  if actions.include?(:update)
        define_method(:log_receiver) { to == :self ? self : send(to) }

        self.log_fields      = fields
        self.excluded_fields = Array(exclude_fields)
      end
    end

    def log_model_creation
      return if should_not_log?

      body_generator = ->(record) { default_creation_log_body(record) }
      body           = log_fields.fetch(:created_at, body_generator).call(self)
      create_log_entry(author_data.merge(body: body, created_at: creation_at))
    end

    def log_model_deletion
      return if should_not_log?

      body_generator = ->(record) { default_deletion_log_body(record) }
      body           = log_fields.fetch(:deleted_at, body_generator).call(self)
      create_log_entry(author_data.merge(body: body))
    end

    def log_model_changes
      return if should_not_log?

      field_changes = previous_changes.reject { |k, _| reject_change?(k) }
      return if field_changes.blank?

      body = field_changes_to_message(field_changes)
      create_log_entry(author_data.merge(body: body)) if body.present?
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

    def create_log_entry(entry)
      log_receiver&.log_entries&.create(entry)
    end

    def creation_at
      return Time.current unless log_receiver == self

      (log_receiver&.log_entries&.order(:created_at)&.first&.created_at || Time.current) - 0.1.seconds
    end

    def default_creation_log_body(record)
      [
        "#{titleized_model_class_name(record)} created",
        ("(#{record.state})" if record.try(:state))
      ].compact.join(" ")
    end

    def default_change_log_body(record, field, _old_value, new_value)
      "#{titleized_model_class_name(record)} #{field.humanize(capitalize: false)} set to #{new_value}"
    end

    def default_deletion_log_body(record)
      [
        "#{titleized_model_class_name(record)} removed",
        ("(#{record.name})" if record.try(:name))
      ].compact.join(" ")
    end

    def field_changes_to_message(changes)
      body_generator = lambda { |record, field, old_value, new_value|
        default_change_log_body(record, field, old_value, new_value)
      }
      changes.inject([]) do |result, (field, (old_value, new_value))|
        result << log_fields.fetch(field.to_sym, body_generator).call(self, field, old_value, new_value)
      end.compact.join("\n")
    end

    def reject_change?(key)
      EXCLUDED_KEYS.include?(key.to_sym) ||
        (!log_fields.include?(key.to_sym) &&
         (excluded_fields.include?(key.to_sym) ||
          EXCLUDED_KEYS_SUFFIXES.any? { |suffix| key.to_s.end_with?(suffix.to_s) }))
    end

    def should_not_log?
      !log_receiver.respond_to?(:log_entries)
    end

    def titleized_model_class_name(record)
      record.class.name.demodulize.titleize
    end
  end
end
