class AddColumnsToSubpages < ActiveRecord::Migration
  def change
    add_column :subpages, :content, :text
  end
end
