module WorthSaving
  class ClassRegistry
    class << self
      def add_entry(klass)
        raise 'Only worth_saving classes may be added' unless klass.is_a?(Class) && klass.worth_saving?
        _entries << klass
      end

      def class_entry(name)
        _entries.select do |klass|
          klass.name == name.to_s.camelcase
        end.first
      end

      private

      def _entries
        @@entries ||= []
      end
    end
  end
end
