require 'action_view'

module WorthSaving
  module ActionViewExt
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
      base.worth_saving_extra_action_view_methods
    end

    module ClassMethods
      def worth_saving_extra_action_view_methods
        # def setup_options!, given the ! not because it changes the caller but b/c it changes the arguments (options)
        # The two separate options arrays are the same except in the case of the 'select' field builder, which has
        #     html_options for HTML attrs rather than using the options hash like the other field builders
        def setup_options!(object_name, field_name, options, html_options = {})
          return unless klass = ActiveRecord::Base.worth_saving_class_with_name(object_name)
          unless klass.worth_saving? field_name
            options[:data] ||= options.delete('data') || {}
            options[:data].merge! worth_saving_exception: true
          end
        end

        alias_method_chain :text_field, :worth_saving_check
        alias_method_chain :select, :worth_saving_check
        alias_method_chain :check_box, :worth_saving_check
        alias_method_chain :text_area, :worth_saving_check
        alias_method_chain :radio_button, :worth_saving_check
        alias_method_chain :form_for, :worth_saving_check
      end

      def worth_saving_form_id
        "worth_saving_form_#{worth_saving_form_number}"
      end

      private

      def worth_saving_form_number
        @@worth_saving_form_number ||= 0
        @@worth_saving_form_number += 1
      end
    end

    # All of these <something>_with_worth... methods will have a .to_s after object_name.  That should be put into the spec
    #    so nobody ever fucks it up.  It passes specs without it unless using the method without being inside a form_for block
    module InstanceMethods
      WORTH_SAVING_DRAFT_FORM_BLOCK = proc { |f|
        f.hidden_field(:recordable_id) +
        f.hidden_field(:recordable_type) +
        f.hidden_field(:scopeable_id) +
        f.hidden_field(:scopeable_type) +
        f.hidden_field(:info)
      }

      def text_field_with_worth_saving_check(object_name, method, options = {})
        self.class.setup_options!(object_name, method, options)
        text_field_without_worth_saving_check(object_name, method, options)
      end

      def select_with_worth_saving_check(object_name, method, choices, options = {}, html_options = {})
        self.class.setup_options!(object_name, method, options, html_options)
        select_without_worth_saving_check(object_name, method, choices, options, html_options)
      end

      def check_box_with_worth_saving_check(object_name, method, options = {}, checked_value = "1", unchecked_value = "0")
        self.class.setup_options!(object_name, method, options)
        check_box_without_worth_saving_check(object_name, method, options, checked_value, unchecked_value)
      end

      def text_area_with_worth_saving_check(object_name, method, options = {})
        self.class.setup_options!(object_name, method, options)
        text_area_without_worth_saving_check(object_name, method, options)
      end

      def radio_button_with_worth_saving_check(object_name, method, tag_value, options = {})
        self.class.setup_options!(object_name, method, options)
        radio_button_without_worth_saving_check(object_name, method, tag_value, options)
      end

      def form_for_with_worth_saving_check(record_or_name_or_array, options = {}, &proc)
        object = [record_or_name_or_array].flatten.last
        dom_id = worth_saving_form_id! object, options
        form_for_without_worth_saving_check(record_or_name_or_array, options, &proc) +
                  worth_saving_draft_form(object, dom_id)
      end

      private

      def worth_saving_form_id!(object, options)
        return unless object.worth_saving?
        options[:data] ||= options['data'] || {}
        self.class.worth_saving_form_id.tap do |form_id|
          options[:data].merge! worth_saving_form_id: form_id
        end
      end

      def worth_saving_draft(object)
        object.worth_saving_draft || object.build_worth_saving_draft
        # WorthSavingDraft.new(
#           recordable_id: object.id,
#           recordable_type: object.class.name,
#           scopeable_id: object.worth_saving_scopeable_id,
#           scopeable_type: object.class.worth_saving_scope_class.name
#         )
      end

      def worth_saving_draft_form(object, dom_id)
        return '' unless object.worth_saving?
        opts = { data: { worth_saving_form: dom_id }, html: { style: 'display: none' } }
        form_for_without_worth_saving_check(worth_saving_draft(object), opts) do |f|
          WORTH_SAVING_DRAFT_FORM_BLOCK.call f
        end
      end
    end
  end
end