module WorthSaving
  module ActiveRecordExt
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
    end

    module ClassMethods
      def worth_saving(opts = {})
        has_one :worth_saving_draft, class_name: 'WorthSaving::Draft', as: :recordable
        set_up_options opts
        register_worth_saving_class
      end

      def worth_saving?(field_name = nil)
        worth_saving_field? field_name
      end

      def worth_saving_classes
        _worth_saving_classes.dup
      end

      def worth_saving_class_with_name(name)
        _worth_saving_classes.find{ |klass| klass.name == name.camelcase }
      end

      private

      def register_worth_saving_class
        _worth_saving_classes << self
      end

      def _worth_saving_classes
        @@worth_saving_classes ||= []
      end

      def set_up_options(opts)
        opts.reverse_merge! except: nil, scope: nil
        @_is_worth_saving = true
        @worth_saving_excluded_fields = [opts[:except]].flatten.compact
        set_up_scoped_draft opts[:scope] unless opts[:scope].nil?
      end

      def worth_saving_field?(field_name)
        return false unless @_is_worth_saving
        !@worth_saving_excluded_fields.include? field_name
      end

      def set_up_scoped_draft(scope)
        if @worth_saving_scope = scope
          @worth_saving_scope_class = scope.to_s.camelcase.constantize
          unless @worth_saving_scope_class.ancestors.include? ActiveRecord::Base
            raise 'Scope must be ActiveRecord::Base subclass'
          end
        end

        class_eval do
          def self.worth_saving_scope
            @worth_saving_scope
          end

          def self.worth_saving_scope_class
            @worth_saving_scope_class
          end

          def worth_saving_draft
            return super if persisted?
            worth_saving_draft_by_scopeable
          end

          def build_worth_saving_draft(opts = {})
            return super if persisted?
            build_worth_saving_draft_by_scopeable opts
          end

          def worth_saving_scopeable_id
            send self.class.worth_saving_scopeable_foreign_key
          end

          private

          def worth_saving_scopeable
            self.class.worth_saving_scope_class.find_by_id worth_saving_scopeable_id
          end

          def build_worth_saving_draft_by_scopeable(opts)
            opts.merge! recordable_type: self.class.name, scopeable: worth_saving_scopeable
            WorthSaving::Draft.new opts
          end

          def self.worth_saving_scopeable_foreign_key
            @worth_saving_scopeable_foreign_key ||= "#{worth_saving_scope}_id"
          end

          def worth_saving_draft_by_scopeable
            WorthSaving::Draft.where(
              scopeable_id: worth_saving_scopeable_id,
              scopeable_type: self.class.worth_saving_scope_class,
              recordable_type: self.class.name
            ).first
          end
        end
      end
    end

    module InstanceMethods
      def worth_saving?(field_name = nil)
        self.class.worth_saving? field_name
      end
    end
  end
end