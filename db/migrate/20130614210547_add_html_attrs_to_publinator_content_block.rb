class AddHtmlAttrsToPublinatorContentBlock < ActiveRecord::Migration
  def change
    add_column :publinator_content_blocks, :html_class, :string
    add_column :publinator_content_blocks, :html_id, :string
    add_column :publinator_content_blocks, :custom_css, :text
  end
end
