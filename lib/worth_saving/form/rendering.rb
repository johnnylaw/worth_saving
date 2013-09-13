module WorthSaving
  module Form
    module Rendering
      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        def render_form
          recovery? ? recovery_forms : standard_form
        end

        private

        def recovery_forms
          form_container 'recovery', recovery_header, main_form_container, recovery_form_container
        end

        def standard_form
          form_container 'standard', main_form_container, draft_status_footer, draft_form_container
        end

        def form_container(type, *elements)
          content = elements.join("\n").html_safe
          @template.content_tag :div, content, class: "worth-saving-#{type}-form-container"
        end

        def main_form_container
          @template.content_tag :div, main_form, form_container_attributes('saved')
        end

        def recovery_form_container
          @template.content_tag :div, recovery_form, form_container_attributes('recovered')
        end

        def draft_form_container
          @template.content_tag :div, draft_form, style: 'display: none'
        end

        def draft_form
          draft_object = draft || object.build_worth_saving_draft
          @template.form_for(draft_object, draft_form_options) do |f|
            WorthSaving::Form::WORTH_SAVING_DRAFT_FORM_BLOCK.call f
          end
        end

        def draft_form_options
          url = @template.worth_saving.drafts_path
          { url: url, html: { data: { worth_saving_draft_form_id: form_id } } }
        end

        def main_form
          @template.form_for record, main_form_options, &@proc
        end

        def main_form_options
          return options if recovery?
          user_data = options.delete(:data) || {}
          options.deep_merge(
            html: {
              data: user_data.merge(
                worth_saving_form_id: form_id,
                worth_saving_interval: @interval,
              )
            }
          )
        end

        def recovery_form
          @template.form_for rescued_record, options.merge(namespace: 'recovered'), &@proc
        end

        def form_container_attributes(form_type)
          {
            id: "worth-saving-#{form_type}-form-container-#{form_id}",
            class: "worth-saving-form-container"
          }
        end

        def recovery_header
          @template.content_tag(:div, RECOVERY_MSG, class: 'worth-saving-header-message')
        end

        def draft_status_footer
          @template.content_tag(:div, '',
            class: 'worth-saving-form-message', id: "worth-saving-form-message-#{form_id}"
          )
        end

        def form_id
          @form_id ||= WorthSaving::FormBuilder.next_form_id
        end
      end
    end
  end
end
