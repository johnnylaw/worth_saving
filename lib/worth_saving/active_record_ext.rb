module WorthSaving
  module ActiveRecordExt
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
    end

    module ClassMethods
      def worth_saving(**opts)
        has_one :worth_saving_draft, as: :recordable
        set_up_options opts
        register_worth_saving_class
      end

      def worth_saving?(field_name = nil)
        worth_saving_field? field_name
      end

      private

      def register_worth_saving_class
        ClassRegistry.add_entry self
      end

      def set_up_options(except: nil)#, scope: nil)
        @_is_worth_saving = true
        @worth_saving_excluded_fields = [except].flatten.compact
      end

      def worth_saving_field?(field_name)
        return false unless @_is_worth_saving
        !@worth_saving_excluded_fields.include? field_name
      end
    end

    module InstanceMethods
      def worth_saving?(field_name = nil)
        self.class.worth_saving? field_name
      end
    end
  end
end

ActiveRecord::Base.send :include, WorthSaving::ActiveRecordExt
