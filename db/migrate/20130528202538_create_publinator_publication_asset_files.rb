class CreatePublinatorPublicationAssetFiles < ActiveRecord::Migration
  def change
    create_table :publinator_publication_asset_files do |t|
      t.integer     :publication_id
      t.integer     :asset_file_id
      t.integer     :position
      t.timestamps
    end
  end
end
