module WorthSaving
  module Form
    class Base
      include WorthSaving::Form::Rendering
      include WorthSaving::Form::Record

      def initialize(template, record, options, &proc)
        @template = template
        @record = record
        @proc = proc
        @interval = options.delete(:interval) || DEFAULT_INTERVAL
        @options = options.merge builder: WorthSaving::FormBuilder
      end

      def render
        options[:worth_saving_recovery] = recovery?
        render_form
      end
    end
  end
end