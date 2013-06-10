class AddRedirectToPublinatorPage < ActiveRecord::Migration
  def change
    add_column :publinator_pages, :redirect_to_child, :boolean
  end
end
