module WorthSaving
  module Form
    module Record
      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        private

        def record
          @record
        end

        def draft
          @draft ||= object.worth_saving_draft
        end

        def options
          @options
        end

        def object
          @object ||= record.is_a?(Array) ? record.last : record
        end

        def recovery?
          # TODO: If a draft is present but reconstituting the draft will provide no additional information
          #       about the record, delete the draft and make recovery false
          @recovery ||= draft.present?
        end

        def rescued_object
          @rescued_object ||= draft && draft.reconstituted_record
        end

        def rescued_record
          if record.is_a? Array
            rescued_record = record.dup
            rescued_record.last = rescued_object
          else
            rescued_record = rescued_object
          end
        end
      end
    end
  end
end