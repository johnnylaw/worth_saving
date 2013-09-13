class Page < ActiveRecord::Base
  attr_accessible :user_id, :user, :title, :content, :subpages_attributes, :approved, :page_type, :position
  is_worth_saving scope: :user
  belongs_to :user

  has_many :subpages
  accepts_nested_attributes_for :subpages
end