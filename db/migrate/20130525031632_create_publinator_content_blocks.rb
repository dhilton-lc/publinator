class CreatePublinatorContentBlocks < ActiveRecord::Migration
  def change
    create_table :publinator_content_blocks do |t|
      t.integer :content_id
      t.string  :content_type
      t.integer :publication_id
      t.integer :layout_order

      t.timestamps
    end
  end
end
