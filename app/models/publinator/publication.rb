module Publinator
  class Publication < ActiveRecord::Base
    # has_paper_trail
    attr_accessible :custom_slug, :parent_id, :publication_state_id,
      :publishable_id, :publishable_type, :site_id, :slug, :publish_at,
      :unpublish_at, :archive_at, :section_id, :default
    belongs_to :publishable, :polymorphic => true
    belongs_to :section
    belongs_to :site

    validates_uniqueness_of :custom_slug, :scope => :site_id, :allow_blank => true
    validates_uniqueness_of :slug, :scope => [:site_id, :publishable_type, :section_id]
    validates_presence_of   :site_id
    validates_associated    :publishable
    #, :publishable_type, :publishable_id

    scope :published, where(:publication_state_id => 1)
    scope :for_site, lambda { |site_id| where("site_id = ?", site_id) }

    before_validation :generate_slug

    def generate_slug
      if self.slug.blank? || self.slug == "Temporary Title"
        if self.custom_slug.present?
          self.slug = self.custom_slug
        elsif publishable.present? && publishable.title.present?
          self.slug = publishable.title.strip.downcase.gsub(" ", "-")
        else
          self.slug = ""
        end
      end
    end

    def self.get_by_slug(slug)
      self.published.where(:slug => slug)
    end
  end
end
