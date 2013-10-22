module WorthSaving
  module ActionViewExt
    def self.included(base)
      base.class_eval do
        def worth_saving_form_for(record, options = {}, &proc)
          WorthSaving::Form::Base.new(self, record, options, &proc).render
        end
      end
    end
  end
end
