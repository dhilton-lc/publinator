class AddArchivedToPublication < ActiveRecord::Migration
  def change
    add_column :publinator_publications, :archived, :boolean, :null => false, :default => false
  end
end
