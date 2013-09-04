class Page < ActiveRecord::Base
  worth_saving #scope: :user, except: :title
  belongs_to :user
end