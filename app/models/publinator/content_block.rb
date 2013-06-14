module Publinator
  class ContentBlock < ActiveRecord::Base
    include RankedModel

    attr_accessible :layout_order, :layout_order_position,
      :publication, :publication_id,
      :content_id, :content_type, :content_attributes,
      :title,
      :area,
      :html_class, :html_id, :custom_css

    belongs_to :content, :polymorphic => true, :autosave => true
    belongs_to :publication

    accepts_nested_attributes_for :content

    ranks :layout_order, :with_same => [ :publication_id, :area ]

    default_scope order('layout_order')
    scope :shared, where( 'publication_id IS NULL' )

    def attributes=(attributes = {})
      # FIXME Validate content type
      self.content_type = attributes[:content_type]
      super
    end

    def content_attributes=(attributes)
      # FIXME Validate content type
      my_content = self.content_type.constantize.find_or_initialize_by_id(self.content_id)
      my_content.attributes = attributes
      self.content = my_content
    end

    def build_content(params)
      self.content = self.content_type.constantize.new(params)
    end

    def shared?
      self.find_shared_source.exists?
    end

    def shared_title
      shared = self.find_shared_source
      return "" unless shared.exists?
      return shared.first.title || "Untitled"
    end

    def find_shared_source
      self.class.shared.where( { :content_type => self.content_type, :content_id => self.content_id } )
    end

    def share(title)
      self.find_shared_source.first_or_create( :title => title, :area => self.area )
    end

    def add_to_all_pages
      unless self.shared?
        raise "Cannot add non-shared block to other pagess!"
      end
      block = self.find_shared_source.first
      Publinator::Publication.find(:all, :conditions => { :site_id => 3 } ).each do |pub|
        if pub.has_block? block
          pblock = pub.get_block block
          pblock.custom_css = block.custom_css
          pblock.html_id = block.html_id
          pblock.html_class = block.html_class
          pblock.save!
        else
          clone = Publinator::ContentBlock.new
          clone.content_type = block.content_type
          clone.content_id = block.content_id
          clone.area = block.area
          clone.title = block.title
          clone.html_class = block.html_class
          clone.html_id = block.html_id
          clone.custom_css = block.custom_css
          pub.content_blocks << clone
          pub.save!
        end
      end #FIXME site_id
    end

    def render
      if self.content.present?
        hclass = ""
        hid = ""
        style = ""
        unless self.html_class.blank?
          hclass = "class='#{self.html_class}'"
        end
        unless self.html_id.blank?
          hid = "id='#{self.html_id}'"
        end
        unless self.custom_css.blank?
          style = "style='#{self.custom_css}'"
        end
        "<div #{hclass} #{hid} #{style}>#{self.content.render}</div>".html_safe
      else
        ""
      end
    end

  end
end
