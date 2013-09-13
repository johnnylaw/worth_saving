class CreateSubpages < ActiveRecord::Migration
  def change
    create_table :subpages do |t|
      t.belongs_to :page, index: true
      t.string :subtitle

      t.timestamps
    end
  end
end
