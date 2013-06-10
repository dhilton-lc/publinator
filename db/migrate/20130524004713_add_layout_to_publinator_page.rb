class AddLayoutToPublinatorPage < ActiveRecord::Migration
  def change
    add_column :publinator_pages, :layout, :boolean
  end
end
