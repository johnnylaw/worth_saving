require "worth_saving/engine"

module WorthSaving
  extend ActiveSupport::Autoload

  autoload :Info
  autoload :FormBuilderMethods
  autoload :Form
  autoload :DraftsControllerMethods

  eager_autoload do
    autoload :ActiveRecordExt
    autoload :ActionViewExt
  end
end

ActiveRecord::Base.send :include, WorthSaving::ActiveRecordExt
ActionView::Base.send :include, WorthSaving::ActionViewExt