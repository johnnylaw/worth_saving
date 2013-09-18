class AddColumnsToPages < ActiveRecord::Migration
  def change
    add_column :pages, :approved, :boolean, default: false
    add_column :pages, :page_type, :string
    add_column :pages, :position, :string
  end
end
