module WorthSaving
  module ActiveRecordExt
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
    end

    module ClassMethods
      def worth_saving(except: nil)
        has_one :worth_saving_draft, as: :recordable
        @except = [except].flatten.compact
        @_is_worth_saving = true
      end

      def worth_saving?(field_name = nil)
        @_is_worth_saving == true && worth_saving_field?(field_name)
      end

      private

      def worth_saving_field?(field_name)
        !@except.include? field_name
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
