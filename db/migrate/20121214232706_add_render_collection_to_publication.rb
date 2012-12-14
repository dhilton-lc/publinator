class AddRenderCollectionToPublication < ActiveRecord::Migration
  def change
    add_column :publinator_publications, :render_collection, :boolean, :default => true
  end
end
