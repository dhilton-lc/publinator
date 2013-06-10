require "publinator/engine"

module Publinator

  def self.options
    @options ||= {
      :layout_options => [ ]
    }
  end

  module ActsAsPublishable
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_publishable(options = {})
        has_one   :publication,
            :as           =>  :publishable,
            :class_name   =>  "Publinator::Publication",
            :foreign_key  =>  :publishable_id,
            :dependent    =>  :destroy

        accepts_nested_attributes_for   :publication
        validates_presence_of           :publication
        validates_associated            :publication

        has_many  :asset_items,
            :as           =>  :assetable,
            :class_name   =>  "Publinator::AssetItem",
            :foreign_key  =>  :assetable_id,
            :order        =>  'position'


        accepts_nested_attributes_for   :asset_items, :reject_if => :all_blank

        before_validation               :verify_publication

        attr_accessible                 :site, :publication, :default,
                                        :row_order, :row_order_position, :asset_items_attributes,
                                        :custom_slug, :site_id,
                                        :publication_attributes

        attr_accessor                   :default

        # FIXME Not sure this is needed anymore
        scope :non_index, joins(:publication).where("publication.slug != 'index'")

        delegate :site, :row_order, :row_order_position, :slug, :hide_in_submenu, :to => :publication
      end
    end

    def is_publishable?
      true
    end

    def asset_types
      []
    end

    def asset_files(asset_type_text = nil)
      return asset_items if !asset_type_text
      asset_items.where(:asset_type => asset_type_text)
    end

    def assets_by_type(asset_type_text = nil)
      return assets if !asset_type_text
      assets.where(:asset_type => asset_type_text)
    end

    def my_slug
      slug
    end

    def related_items(scope)
      []
    end

    def hidden_fields
      []
    end

    def editable_fields
      attribute_names - (["id", "created_at", "updated_at"] + hidden_fields)
    end

    def pub_path
      raise "publication not found" if !self.publication

      if self.publication.publishable_type == "Publinator::Page"
        if self.is_root?
          if self.title == "Home"
            "/"
          else
            "/#{self.publication.slug}"
          end
        elsif self.publication.parent.is_root?
          "/#{self.publication.slug}"
        else
          "#{self.publication.parent.publishable.pub_path}/#{self.publication.slug}"
        end
      elsif self.publication.publishable_type == "Publinator::Page"
        "/#{self.publication.slug}"
      elsif self.publication.publishable_type == "Publinator::PublishableType"
        "/#{self.title.pluralize.underscore}"
      else
        "/#{self.class.to_s.tableize}/#{self.publication.slug}"
      end
    end

    def url
      site.url(pub_path)
    end

    def menu_collection
      nil
    end

    def menu_label_text
      if self.publication.menu_label.blank?
        self.title
      else
        self.publication.menu_label
      end
    end

    def verify_publication
      if publication.nil?
        self.publication = Publinator::Publication.new(:publishable => self)
      end
      self.publication.site     = site unless publication.site.present?
      self.publication.default  = default
    end
  end
end

ActiveRecord::Base.send :include, Publinator::ActsAsPublishable

