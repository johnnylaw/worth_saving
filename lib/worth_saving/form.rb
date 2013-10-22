module WorthSaving
  module Form
    extend ActiveSupport::Autoload

    autoload :Record
    autoload :Rendering
    autoload :Base

    WORTH_SAVING_DRAFT_FORM_BLOCK = proc { |f|
      f.hidden_field(:recordable_id) +
      f.hidden_field(:recordable_type) +
      f.hidden_field(:scopeable_id) +
      f.hidden_field(:scopeable_type) +
      f.hidden_field(:form_data)
    }
  end
end
