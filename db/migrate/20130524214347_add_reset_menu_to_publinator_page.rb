class AddResetMenuToPublinatorPage < ActiveRecord::Migration
  def change
    add_column :publinator_pages, :reset_menu, :boolean
  end
end
