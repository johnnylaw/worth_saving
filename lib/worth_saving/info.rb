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

    def scope_class
      @scope_class
    end

    def scopeable_id(recordable)
      recordable.send scopeable_foreign_key
    end

    def scopeable(recordable)
      scope_class.find_by_id scopeable_id(recordable)
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
      opts[:scope] ? set_up_scoped_draft(opts[:scope]) : set_up_unscoped_draft
    end

    def set_up_unscoped_draft
      @klass.class_eval do
        def worth_saving_draft
          @worth_saving_draft ||=
            WorthSaving::Draft.where(recordable_type: self.class.name, recordable_id: id).first
        end
      end
    end

    def set_up_scoped_draft(scope)
      @scope = scope
      @scope_class = scope.to_s.camelcase.constantize

      @klass.class_eval do
        def build_worth_saving_draft(opts = {})
          build_worth_saving_draft_by_scopeable opts
        end

        def worth_saving_draft
          worth_saving_draft_by_scopeable
        end

        private

        def build_worth_saving_draft_by_scopeable(opts)
          opts.merge! recordable: self, scopeable: self.class.worth_saving_info.scopeable(self)
          WorthSaving::Draft.new opts
        end

        def worth_saving_draft_by_scopeable
          info = self.class.worth_saving_info
          WorthSaving::Draft.where(
            recordable_type: self.class.name,
            recordable_id: id,
            scopeable_type: info.scope_class,
            scopeable_id: info.scopeable_id(self)
          ).first
        end
      end
    end

    def scopeable_foreign_key
      @scopeable_foreign_key ||= "#{@scope}_id"
    end
  end
end