require "worth_saving/engine"
require 'worth_saving/info'
require 'worth_saving/active_record_ext'
require 'worth_saving/form_builder'
require 'worth_saving/form'
require 'worth_saving/action_view_ext'
require 'worth_saving/drafts_controller_methods'

module WorthSaving
end

ActiveRecord::Base.send :include, WorthSaving::ActiveRecordExt
ActionView::Base.send :include, WorthSaving::ActionViewExt