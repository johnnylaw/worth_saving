require "worth_saving/engine"
require 'worth_saving/info'
require 'worth_saving/active_record_ext'

module WorthSaving
end

ActiveRecord::Base.send :include, WorthSaving::ActiveRecordExt