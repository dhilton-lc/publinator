class AddSiteIdToPublishableType < ActiveRecord::Migration
  def change
    add_column :publinator_publishable_types, :site_id, :integer
  end
end
