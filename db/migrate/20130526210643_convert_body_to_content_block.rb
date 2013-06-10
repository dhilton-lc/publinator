class ConvertBodyToContentBlock < ActiveRecord::Migration
  def up
    Publinator::Page.all.each do |p|
      block = Publinator::ContentBlock.new :publication_id => p.publication.id, :content_type => "Publinator::MarkdownContent"
      block.build_content :body => p.body
      block.save!
    end
  end

  def down
    # We're leaving 'body' intact, for now, so no down is really necessary
    # Well, technically we should remove all the content blocks created by this migration.
    # Oh, well.
  end
end
