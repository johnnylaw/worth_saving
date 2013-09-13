module WorthSaving
  class Info
    attr_reader :scope

    def initialize(klass, opts)
      register_class klass
      set_up_options opts
    end

    def self.class_with_name(name)
      classes.find{ |klass| klass.name == name.camelcase }
    end

    def self.attribute_whitelisting_required?
      Rails.version.match(/^3/).present? || defined?(ProtectedAttributes) == 'constant'
    end

    def saves_field?(field)
      !@excluded_fields.include? field
    end

    private

    def self.classes
      @@classes ||= []
    end

    def register_class(klass)
      @klass = klass
      self.class.classes << klass
    end

    def set_up_options(opts)
      opts.reverse_merge! except: nil, scope: nil
      @excluded_fields = [opts[:except]].flatten.compact
      @excluded_fields.concat Rails.application.config.filter_parameters
      set_up_scoped_draft opts[:scope]
    end

    def set_up_scoped_draft(scope)
      return unless @scope = scope
      @scope_class = scope.to_s.camelcase.constantize

      @klass.class_eval do
        def build_worth_saving_draft(opts = {})
          return super if persisted?
          self.class.worth_saving_info.build_worth_saving_draft_by_scopeable self, opts
        end

        def worth_saving_draft
          return super if persisted?
          self.class.worth_saving_info.draft_by_scopeable self
        end
      end

      class_eval do
        def build_worth_saving_draft_by_scopeable(recordable, opts)
          opts.merge! recordable_type: @klass.name, scopeable: scopeable(recordable)
          WorthSaving::Draft.new opts
        end

        def draft_by_scopeable(recordable)
          WorthSaving::Draft.where(
            scopeable_id: scopeable_id(recordable),
            scopeable_type: scope_class,
            recordable_type: recordable.class.name
          ).first
        end

        private

        def scope_class
          @scope_class
        end

        def scopeable_id(recordable)
          recordable.send scopeable_foreign_key
        end

        def scopeable(recordable)
          scope_class.find_by_id scopeable_id recordable
        end

        def scopeable_foreign_key
          @scopeable_foreign_key ||= "#{@scope}_id"
        end
      end
    end
  end
end