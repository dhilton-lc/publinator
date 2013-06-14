class AddAreaToContentBlock < ActiveRecord::Migration
  def change
    add_column :publinator_content_blocks, :area, :string
  end
end
