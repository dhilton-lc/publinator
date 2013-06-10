module Publinator
  class Page < ActiveRecord::Base

    include RankedModel

    self.table_name = 'publinator_pages'

    acts_as_publishable

    attr_accessible :kicker, :subtitle, :teaser, :title, :section, :section_id, :asset_items, :asset_item, :asset_file, :layout, :my_layout, :default_layout, :row_order, :row_order_position, :ancestry, :reset_menu, :redirect_to_child, :site_id, :parent_id


    belongs_to :section, :class_name => "Publinator::Page"

    ranks :row_order, :with_same => [:ancestry, :site_id]

    has_ancestry :orphan_strategy => :adopt

    default_scope order('publinator_pages.row_order') # FIXME

    def hidden_fields
      %w{body site_id kicker teaser section_id ancestry row_order_position row_order layout custom_slug}
    end

    # Render and concatenate all content blocks, return the result
    # TODO: Create different areas (body, sidebar, header, footer, etc.), and allow placing content blocks in any area.
    # When that is done, 'body' of course will only render the blocks in the page's 'body' area
    # Also, this really belongs to 'publishable'!!!! FIXME
    def body
      rendered_blocks = []
      self.publication.content_blocks.each do |block|
        rendered_blocks << block.render
      end
      # TODO: block and/or area and/or page-level caching

      rendered_blocks.join("\n").html_safe
    end

    def menu_root
      mroot = self.path.find(:last, :conditions => { :reset_menu => true } )
      unless mroot
        mroot = Publinator::Page.find(:first, :conditions => { :title => "Home" } ) # FIXME
      end

      return mroot
    end

    # SUPER FIXME Migrate these methods to publication.rb

    def child_layout
      if ! self.default_layout.blank?
        self.default_layout
      elsif ! self.my_layout.blank?
        self.my_layout
      elsif self.publication.is_root?
        'about' # FIXME!!!!!!
      else
        self.publication.parent.publishable.child_layout
      end
    end

    def page_layout
      if ! self.my_layout.blank?
        if ( self.my_layout == '_none_' )
          nil
        else
          self.my_layout
        end
      elsif self.publication.is_root?
        'home' # FIXME!!!!!
      else
        self.publication.parent.publishable.child_layout
      end
    end

    def asset_types
      ['header','pdf_document']
    end

    def name
      title
    end

    def publishables
      (self.asset_files - self.asset_files('header')).sort_by{|asset_file| asset_file.position}
    end

    def menu_collection
      children
    end

    def breadcrumb_path
      return self.path
    end

    def self.decompose_slug(slug)
      home = self.where(:title => "Home").first # FIXME Identify home page more better! Also, filter by site_id?
      if ( slug == "" || slug == "/" )
        return home
      else
        pages = slug.split '/'
        node = home
        while pages.count > 0
          pslug = pages.shift
          if node.children.joins(:publication).exists?( :publinator_publications => { :slug => pslug } )
            node = node.children.joins(:publication).find(:first, :conditions => { :publinator_publications => { :slug => pslug } })
          else
            return nil
          end
        end
        if ( node.redirect_to_child )
          return node.children.first
        else
          return node
        end
      end
    end

    if ThinkingSphinx
      define_index do
        indexes title
        indexes body
        indexes subtitle
        has created_at, updated_at
      end
    end

  end
end
