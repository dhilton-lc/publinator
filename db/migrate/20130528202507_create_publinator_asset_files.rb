class CreatePublinatorAssetFiles < ActiveRecord::Migration

  def change
    create_table :publinator_asset_files do |t|
      t.string      :asset_type
      t.string      :asset_file_name
      t.string      :asset_content_type
      t.datetime    :asset_updated_at
      t.integer     :asset_file_size
      t.timestamps
    end
  end
end
