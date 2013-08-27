class CreateWorthSavingDrafts < ActiveRecord::Migration
  def change
    create_table :worth_saving_drafts do |t|
      t.integer :recordable_id
      t.string  :recordable_type
      t.integer :scopable_id
      t.string  :scopable_type
      t.text    :info

      t.timestamps
    end
    add_index :worth_saving_drafts, [:recordable_id, :recordable_type], name: :worth_saving_draft_index, unique: true
  end
end