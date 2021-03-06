module WorthSaving
  module FormBuilderMethods
    SIMPLE_FIELD_HELPERS = [
      :text_field, :hidden_field, :text_area, :search_field,
      :telephone_field, :phone_field, :url_field, :email_field,
      :number_field, :range_field
    ]

    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      SIMPLE_FIELD_HELPERS.each do |helper|
        module_eval <<-EOS
          def #{helper}(method, options = {})
            process_options! method, options
            super
          end
        EOS
      end

      def input(method, input_options = {})
        process_options! method, input_options
        super
      end

      def radio_button(method, tag_value, options = {})
        process_options! method, options
        super
      end

      def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
        process_options! method, options
        super
      end

      def select(method, choices, options = {}, html_options = {})
        process_options! method, html_options, options
        super
      end

      def date_select(method, options = {}, html_options = {})
        process_options! method, html_options
        super
      end

      def fields_for(record_name, options = {}, &bloc)
        options[:builder] = options[:builder].superclass unless object.worth_saving? record_name
        super
      end

      def submit(value = nil, options = {})
        value = 'Choose this copy' if self.options[:worth_saving_recovery]
        super
      end

      private

      def process_options!(method, options, addl_options = {})
        if object.worth_saving?(method) && options[:worth_saving] != false && addl_options[:worth_saving] != false
          options[:data] ||= options.delete('data') || {}
          options[:data].merge! worth_saving: true
        end
      end
    end
  end
end