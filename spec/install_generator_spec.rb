require 'worth_saving'
require "generator_spec/test_case"

describe WorthSaving::Generators::InstallGenerator do
  include GeneratorSpec::TestCase
  destination File.expand_path("../../tmp", __FILE__)

  before do
    prepare_destination
    run_generator
  end

  specify do
    destination_root.should have_structure {
      # no_file "non_existant.rb"
      directory "app" do
        directory "models" do
          file "worth_saving_draft.rb" do
            contains <<-EOS
class WorthSavingDraft < ActiveRecord::Base
end
            EOS
          end
        end
      end
      directory "db" do
        directory "migrate" do
          migration "create_worth_saving_drafts" do
            contains <<-EOS
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
    add_index :worth_saving_drafts, [:recordable_type, :scopeable_id, :scopeable_type], name: :worth_saving_draft_scopeable_index, unique: true
  end
end
            EOS
          end
        end
      end
    }
  end
end