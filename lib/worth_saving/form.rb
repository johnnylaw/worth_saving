require 'worth_saving/form/record'
require 'worth_saving/form/rendering'
require 'worth_saving/form/base'

module WorthSaving
  module Form
    DEFAULT_INTERVAL = 60
    WORTH_SAVING_DRAFT_FORM_BLOCK = proc { |f|
      f.hidden_field(:recordable_id) +
      f.hidden_field(:recordable_type) +
      f.hidden_field(:scopeable_id) +
      f.hidden_field(:scopeable_type) +
      f.hidden_field(:form_data)
    }
    RECOVERY_MSG = <<EOS
It appears you were working on a draft that didn't get saved.
It is recommended that you choose one now, as no more draft copies will be saved until you do.
EOS
  end
end
