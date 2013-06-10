class AddLayoutsToPublicationPage < ActiveRecord::Migration
  def change
    add_column :publinator_pages, :my_layout, :string
    add_column :publinator_pages, :default_layout, :string
  end
end
