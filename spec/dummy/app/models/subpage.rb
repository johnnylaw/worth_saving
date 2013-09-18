class Subpage < ActiveRecord::Base
  attr_accessible :page_id, :subtitle, :content
  is_worth_saving
  belongs_to :page

  delegate :owner, to: :page
end
