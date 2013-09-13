module WorthSaving
  module ActiveRecordExt
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
    end

    module ClassMethods
      def is_worth_saving(opts = {})
        class_eval do
          has_one :worth_saving_draft, class_name: 'WorthSaving::Draft', as: :recordable
          after_save :destroy_worth_saving_draft

          @worth_saving_info = WorthSaving::Info.new self, opts

          def self.worth_saving_info
            @worth_saving_info
          end

          private

          def destroy_worth_saving_draft
            worth_saving_draft && worth_saving_draft.destroy
          end
        end
      end

      def worth_saving?(field_name = nil)
        respond_to?(:worth_saving_info) && worth_saving_info.saves_field?(field_name)
      end
    end

    module InstanceMethods
      def worth_saving?(field_name = nil)
        self.class.worth_saving? field_name
      end
    end
  end
end
