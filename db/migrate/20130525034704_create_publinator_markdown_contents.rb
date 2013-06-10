class CreatePublinatorMarkdownContents < ActiveRecord::Migration
  def change
    create_table :publinator_markdown_contents do |t|
      t.text :body

      t.timestamps
    end
  end
end
