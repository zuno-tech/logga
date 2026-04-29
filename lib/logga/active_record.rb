# frozen_string_literal: true

module Logga
  module ActiveRecord
    extend ActiveSupport::Concern

    included do
      class_attribute :logga_options, instance_writer: false

      # self.logga_options = nil
    end

    class_methods do
      def add_log_entries_for(*actions, **options)
        configure_logga_options(options)
        setup_logga_callbacks(actions)
        define_logga_receiver_method
      end

      def configure_logga_options(options)
        default_logga_options = {
          allowed_fields: [],
          excluded_fields: [],
          fields: {},
          class_name: nil,
          to: :itself
        }
        self.logga_options = default_logga_options.merge(options.slice(:allowed_fields, :fields, :class_name, :to))
        return if options[:allowed_fields].present?

        self.logga_options = logga_options.merge(excluded_fields: options[:exclude_fields] || [])
      end

      def setup_logga_callbacks(actions)
        after_create :log_model_creation if actions.include?(:create)
        after_destroy :log_model_deletion if actions.include?(:delete)
        after_update :log_model_changes if actions.include?(:update)
      end

      def define_logga_receiver_method
        define_method(:log_receiver) { send(logga_options[:to]) }
      end

      private :configure_logga_options, :setup_logga_callbacks, :define_logga_receiver_method
    end

    def log_field_changes(changes)
      return if changes.blank?

      body = field_changes_to_message(changes)
      return if body.blank?

      create_log_entry(author_data.merge(body:))
    end

    def log_model_creation
      return unless should_log?

      body_generator = ->(record) { default_creation_log_body(record) }
      body = logga_options[:fields].fetch(:created_at, body_generator).call(self)
      create_log_entry(author_data.merge(body:, created_at: creation_at))
    end

    def log_model_deletion
      return unless should_log?

      body_generator = ->(record) { default_deletion_log_body(record) }
      body = logga_options[:fields].fetch(:deleted_at, body_generator).call(self)
      create_log_entry(author_data.merge(body:))
    end

    def log_model_changes
      return unless should_log?

      field_changes = previous_changes.reject { |k, _| reject_change?(k) }
      log_field_changes(field_changes)
    end

    private

    def author_data
      data = Hash(log_receiver.try(:author) || try(:author)).with_indifferent_access

      {
        author_id: data[:id],
        author_name: data[:name],
        author_type: data[:type]
      }
    end

    def config_excluded_fields
      Logga.configuration.excluded_fields
    end

    def config_excluded_suffixes
      Logga.configuration.excluded_suffixes
    end

    def create_log_entry(entry)
      log_receiver.log_entries&.create(entry)
    end

    def creation_at
      return Time.current unless log_receiver == self

      (log_receiver.log_entries.order(:created_at).first&.created_at || Time.current) - 0.1.seconds
    end

    def default_creation_log_body(record)
      "#{titleized_model_class_name(record)} created"
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
        result << logga_options[:fields].fetch(field.to_sym, body_generator).call(self, field, old_value, new_value)
      end.compact.join("\n")
    end

    def reject_change?(key)
      sym_key = key.to_sym
      return logga_options[:allowed_fields].exclude?(sym_key) if logga_options[:allowed_fields].present?

      excluded_change?(key, sym_key)
    end

    def excluded_change?(key, sym_key)
      config_excluded_fields.include?(sym_key) ||
        (logga_options[:fields].exclude?(sym_key) &&
          (logga_options[:excluded_fields].include?(sym_key) ||
             config_excluded_suffixes.any? { |suffix| key.to_s.end_with?(suffix.to_s) }))
    end

    def should_log?
      Logga.enabled? && log_receiver.respond_to?(:log_entries)
    end

    def titleized_model_class_name(record)
      logga_options[:class_name] || record.class.name.demodulize.titleize
    end
  end
end
