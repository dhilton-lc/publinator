module Publinator
  class PublishableType < ActiveRecord::Base

    acts_as_publishable

    attr_accessible :name, :sluggable, :layout, :use_layout, :position, :site_id
    alias_attribute :title, :name

    def publishable_class
      self.name.constantize
    end

    def collection_name
      return self.name.pluralize.titleize
    end

    def self.matches?(request)
      pt = self.find_by_name(request.path_parameters[:publishable_type].singularize.capitalize)
      return pt.present?
    end
  end
end
