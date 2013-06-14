class AddTitleToPublinatorContentBlock < ActiveRecord::Migration
  def change
    add_column :publinator_content_blocks, :title, :string
  end
end
