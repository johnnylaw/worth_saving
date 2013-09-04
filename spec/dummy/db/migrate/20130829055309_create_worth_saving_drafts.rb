class CreateWorthSavingDrafts < ActiveRecord::Migration
  def change
    create_table :worth_saving_drafts do |t|
      t.integer :recordable_id
      t.string  :recordable_type
      t.integer :scopeable_id
      t.string  :scopeable_type
      t.text    :info

      t.timestamps
    end

    add_index :worth_saving_drafts, [:recordable_id, :recordable_type], name: :worth_saving_draft_recordable_index
    add_index :worth_saving_drafts, [:recordable_type, :scopeable_id, :scopeable_type], name: :worth_saving_draft_scopeable_index
  end
end
