class AddAncestryToPublication < ActiveRecord::Migration
  def up
    add_column :publinator_publications, :ancestry, :string
    rename_column :publinator_publications, :position, :row_order
    add_index :publinator_publications, :ancestry

    # Convert page ancestry to publication ancestry
    Publinator::Publication.all.each do |pub|
      if pub.publishable_type == 'Publinator::Page' and pub.publishable.ancestry
        page_ancestry = pub.publishable.ancestry.split('/')
        publication_ancestry = []
        page_ancestry.each do |page_id|
          page = Publinator::Page.find(page_id)
          publication_ancestry << page.publication.id
        end
        pub.ancestry = publication_ancestry.join('/')
        pub.save!
      end
    end

  end

  def down
    remove_index :publinator_publications, :column => :ancestry
    remove_column :publinator_pblications, :ancestry
    rename_column :publinator_publications, :row_order, :position
  end
end
