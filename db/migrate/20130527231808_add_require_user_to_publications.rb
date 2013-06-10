class AddRequireUserToPublications < ActiveRecord::Migration
  def change
    add_column :publinator_publications, :require_user, :boolean
  end
end
