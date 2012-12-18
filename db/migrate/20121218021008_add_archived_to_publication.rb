class AddArchivedToPublication < ActiveRecord::Migration
  def change
    add_column :publinator_publications, :archived, :boolean
  end
end
