class WorthSavingWithoutAuthorRecord < ActiveRecord::Base
  self.table_name = 'records'
  worth_saving except: :author
end