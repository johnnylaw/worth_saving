class Page < ActiveRecord::Base
  attr_accessible :user_id, :user, :title, :content, :author_id, :subpages_attributes, :approved, :page_type, :position
  is_worth_saving scope: :user
  belongs_to :user
  belongs_to :author

  has_many :subpages
  accepts_nested_attributes_for :subpages

  def owner
    user
  end
end