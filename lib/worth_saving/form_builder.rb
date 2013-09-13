module WorthSaving
  class FormBuilder < ActionView::Base.default_form_builder
    def self.default_interval
      3
    end

    WORTH_SAVING_DRAFT_FORM_BLOCK = proc { |f|
      f.hidden_field(:recordable_id) +
      f.hidden_field(:recordable_type) +
      f.hidden_field(:scopeable_id) +
      f.hidden_field(:scopeable_type) +
      f.hidden_field(:form_data)
    }

    def text_field(method, options = {})
      process_options! method, options
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

    def text_area(method, options = {})
      process_options! method, options
      super
    end

    def hidden_field(method, options = {})
      process_options! method, options
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

    def self.next_form_id
      @@worth_saving_form_id ||= 0
      @@worth_saving_form_id += 1
    end

    private

    def process_options!(method, options)
      if object.worth_saving? method
        options[:data] ||= options.delete('data') || {}
        options[:data].reverse_merge! worth_saving: true
      end
    end
  end
end