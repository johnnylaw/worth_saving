require 'worth_saving/active_record_ext'

ActiveRecord::Base.send :include, WorthSaving::ActiveRecordExt
