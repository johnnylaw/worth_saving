class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.string :title
      t.string :description
      t.string :author
      t.text :content

      t.timestamps
    end
  end
end
