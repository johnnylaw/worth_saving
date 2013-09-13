module WorthSaving
  module ActionViewExt
    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def worth_saving_form_for(record, options = {}, &proc)
        object = record.is_a?(Array) ? record.last : record
        form_id = WorthSaving::FormBuilder.next_form_id
        interval = options.delete(:interval) || WorthSaving::FormBuilder.default_interval
        options.merge! builder: WorthSaving::FormBuilder
        in_recovery_mode = false

        if object.worth_saving_draft.present?
          rescued_object = object.worth_saving_draft.reconstituted_record
          if rescued_object.attributes == object.attributes
            object.worth_saving_draft.destroy
          else
            in_recovery_mode = true
          end
        end

        if in_recovery_mode
          options[:worth_saving_recovery] = true
          header_content = content_tag(
            :div, "It appears you were working on a draft that didn't get saved. It is recommended that you choose one now, as no more draft copies will be saved until you do.", class: 'worth-saving-header-message'
          )
          outer_container_type = 'double'
          if record.is_a? Array
            rescued_record = record.dup
            rescued_record.last = rescued_object
          else
            rescued_record = rescued_object
          end
          second_form = content_tag(
            :div,
            form_for(rescued_record, options, &proc),
            id: "worth-saving-recoverd-form-container-#{form_id}", class: "worth-saving-form-container"
          )
        else object.worth_saving_draft
          header_content = ''.html_safe
          user_data = options.delete(:data) || {}
          outer_container_type = 'single'

          options.deep_merge!(
            html: {
              data: user_data.merge(
                worth_saving_form_id: form_id,
                worth_saving_interval: interval,
              )
            }
          )

          draft = object.worth_saving_draft || object.build_worth_saving_draft
          url = draft.persisted? ? worth_saving.draft_path(draft) : worth_saving.drafts_path
          draft_form_options = { html: { data: { worth_saving_draft_form_id: form_id } }, url: url }
          second_form = content_tag(:div, '', class: 'worth-saving-form-message', id: "worth-saving-form-message-#{form_id}") +
            content_tag(
              :div,
              form_for(draft, draft_form_options) do |f|
                WorthSaving::FormBuilder::WORTH_SAVING_DRAFT_FORM_BLOCK.call f
              end,
              style: 'display: none'
            )
        end
        content_tag(
          :div,
          header_content +
            content_tag(
              :div,
              form_for(record, options, &proc),
              id: "worth-saving-saved-form-container-#{form_id}", class: "worth-saving-form-container"
            ) + "\n" + second_form,
          class: "worth-saving-#{outer_container_type}-form-container"
        )
      end
    end
  end
end