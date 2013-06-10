class AddAncestryToPage < ActiveRecord::Migration
  def change
    add_column :publinator_pages, :ancestry, :string
    add_index :publinator_pages, :ancestry
  end
end
