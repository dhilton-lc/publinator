class AddTitleDescriptionToPublinatorPublications < ActiveRecord::Migration
  def change
    add_column :publinator_publications, :title_tag, :string
    add_column :publinator_publications, :meta_description, :string
  end
end
