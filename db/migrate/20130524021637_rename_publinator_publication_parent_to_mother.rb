class RenamePublinatorPublicationParentToMother < ActiveRecord::Migration
  def change
    rename_column :publinator_publications, :parent_id, :mother_id
  end
end
