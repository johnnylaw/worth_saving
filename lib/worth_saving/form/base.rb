module WorthSaving
  module Form
    class Base
      include WorthSaving::Form::Rendering
      include WorthSaving::Form::Record

      def initialize(template, record, options, &proc)
        @template = template
        @record = record
        @proc = proc
        @interval = options.delete(:save_interval) || WorthSaving::Engine.config.default_save_interval
        @options = options
      end

      def render
        options[:worth_saving_recovery] = recovery?
        options[:builder] = form_builder
        render_form
      end

      def self.next_form_id
        @@worth_saving_form_id ||= 0
        @@worth_saving_form_id += 1
      end

      private

      def form_builder(existing = WorthSaving, extensions = nil)
        extensions ||= parent_builder.to_s.split('::').map(&:to_sym)
        if extensions.size > 1
          return define_module existing, extensions
        end
        define_class existing, extensions.first
      end

      def define_module(existing, extensions)
        extension = extensions.shift
        existing.module_eval "module #{extension}; end"
        form_builder(eval("#{existing}::#{extension}"), extensions)
      end

      def define_class(existing, klass)
        unless existing.constants.include? klass
          existing.module_eval <<-EOS
            class #{klass} < ::#{parent_builder}
              include WorthSaving::FormBuilderMethods
            end
          EOS
        end
        eval "#{existing}::#{klass}"
      end

      def parent_builder
        @parent_builder ||= @options[:parent_builder] || ::ActionView::Base.default_form_builder
      end
    end
  end
end