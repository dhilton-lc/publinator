class CreatePublinatorPublications < ActiveRecord::Migration
  def change
    create_table :publinator_publications do |t|
      t.integer     :site_id
      t.integer     :publication_state_id
      t.integer     :parent_id
      t.integer     :section_id
      t.string      :custom_slug
      t.string      :slug
      t.datetime    :publish_at
      t.datetime    :unpublish_at
      t.datetime    :archive_at
      t.string      :publishable_type
      t.integer     :publishable_id
      t.boolean     :default

      t.timestamps
    end
    add_index :publinator_publications, :site_id
    add_index :publinator_publications, :publication_state_id
  end
end
