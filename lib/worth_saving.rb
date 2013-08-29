require 'worth_saving/active_record_ext'
require 'worth_saving/action_view_ext'

ActiveRecord::Base.send :include, WorthSaving::ActiveRecordExt
ActionView::Base.send :include, WorthSaving::ActionViewExt
