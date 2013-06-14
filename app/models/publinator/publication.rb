module Publinator
  class Publication < ActiveRecord::Base
    # has_paper_trail
    include RankedModel
    attr_accessible :custom_slug, :mother_id, :publication_state_id,
      :publishable_id, :publishable_type, :slug, :publish_at, :hide_in_submenu,
      :unpublish_at, :archive_at, :section, :default, :publishable, :site,
      :section_id, :collection_publishable_type_id, :collection_scope, :render_collection,
      :title_tag, :meta_description, :row_order, :row_order_position, :ancestry, :site_id,
      :menu_label,
      :archived, # FIXME: Temporary fix in anticipation of more complete workflow management
      :require_user,
      :assets_attributes,
      :publication_asset_files_attributes,
      :parent_id

    belongs_to :publishable, :polymorphic => true
    belongs_to :section, :class_name => "Publinator::Section"
    belongs_to :site

    has_many :content_blocks

    has_many :publication_asset_files, :class_name => "Publinator::PublicationAssetFile"
    has_many :assets, :class_name => "Publinator::AssetFile", :through => :publication_asset_files, :source => :asset_file do
      def <<(new_asset)
        super( Array(new_asset) - proxy_association.owner.assets )
      end
    end

    ranks :row_order, :with_same => [:ancestry, :publishable_type]

    has_ancestry :orphan_strategy => :adopt

    default_scope order('row_order')

    # TODO: Not sure if this will work
    accepts_nested_attributes_for :publication_asset_files, :reject_if => :all_blank
    accepts_nested_attributes_for :assets, :reject_if => :all_blank

    validates_uniqueness_of :custom_slug, :scope => [:site_id, :section_id, :publishable_type], :allow_blank => true
    # validates_uniqueness_of :slug, :scope => [:site_id, :section_id, :publishable_type] # FIXME "section" pages duplicate slugs of their 'index' page
    validates_presence_of   :site

    before_validation :generate_slug
    before_save       :generate_slug

    scope :published, where(:publication_state_id => 1)
    scope :archived, where( :archived => true )
    scope :active, where( :archived => false )
    scope :for_site, lambda { |site_id| where("site_id = ?", site_id) }
    scope :orphans, where(:section_id => nil)
    default_scope order('row_order')

    delegate :title, :pub_path, :menu_collection, :to => :publishable

    def collection
      return nil unless collection_publishable_type_id
      pt = Publinator::PublishableType.find(collection_publishable_type_id)
      return nil if !pt
      if collection_scope.blank?
        pt.name.constantize.send( :all )
      else
        pt.name.constantize.send( collection_scope.to_sym )
      end
    end

    def content
      publishable_type.constantize.find(publishable_id)
    end

    def generate_slug
      if self.slug.blank? || slug =~ /temporary_slug_\d?/ || custom_slug.present? || default
        if default
          self.slug = 'index'
        elsif custom_slug.present?
          self.slug = custom_slug
        elsif publishable.present? && publishable.title.present?
          self.slug = self.publishable.title.strip.downcase.gsub(/[^a-zA-Z0-9\-\_]/, '_')
          self.slug = self.slug.gsub("___", "_")
          self.slug = self.slug.gsub("__", "_")
          if slug.end_with?("_")
            self.slug = self.slug.chop
          end
        else
          self.slug = "temporary_slug_#{rand(100000)}"
        end
      end
    end

    def self.get_by_slug(slug)
      #self.published.where(:slug => slug)
      self.where(:slug => slug)
    end

    def self.decompose_slug(slug)
      home = Publinator::Page.where(:title => "Home").first.publication # FIXME Identify home page more better! Also, filter by site_id?
      if ( slug == "" || slug == "/" )
        return home
      else
        pages = slug.split '/'
        node = home
        while pages.count > 0
          pslug = pages.shift
          if node.children.exists?( :slug => pslug )
            node = node.children.find( :first, :conditions => { :slug => pslug } )
          else
            return nil
          end
        end
        if ( node.publishable.respond_to?( :redirect_to_child ) && node.publishable.redirect_to_child ) #FIXME
          return node.children.first
        else
          return node
        end
      end
    end

    def get_block( block )
      self.content_blocks.where( {:content_type => block.content_type, :content_id => block.content_id } ).first
    end

    def has_block?( block )
      self.content_blocks.where( { :content_type => block.content_type, :content_id => block.content_id } ).exists?
    end

  end
end
